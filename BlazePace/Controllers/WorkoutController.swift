import Foundation
import HealthKit
import Combine

@MainActor
class WorkoutController: NSObject, ObservableObject {
    private struct ActiveSessionObjects {
        let session: HKWorkoutSession
        let builder: HKLiveWorkoutBuilder
        let paceAlertController: PaceAlertController
        let paceController: PaceController
    }

    static let shared = WorkoutController()

    @Published var viewModel: WorkoutViewModel?

    private let healthStore = HKHealthStore()
    private let log = Log(name: "WorkoutController")
    private var activeSessionObjects: ActiveSessionObjects?

    private override init() {}

    // MARK: - Internal methods

    func startWorkout(_ startData: WorkoutStartData) async -> Bool {
        guard activeSessionObjects == nil else { fatalError("A workout is already active") }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = startData.workoutType.healthKitType
        configuration.locationType = .outdoor

        let session: HKWorkoutSession
        let builder: HKLiveWorkoutBuilder

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session.associatedWorkoutBuilder()
        } catch {
            log.error("Failed to start workout: \(error)")
            return false
        }

        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        session.delegate = self
        builder.delegate = self

        do {
            session.startActivity(with: Date())
            try await builder.beginCollection(at: Date())
        } catch {
            log.error("Failed to begin collection: \(error)")
            return false
        }

        log.info("Workout setup OK")

        await MainActor.run {
            viewModel = WorkoutViewModel(workoutType: startData.workoutType, targetPace: startData.targetPace)
            viewModel!.delegate = self
        }

        guard let viewModel else { fatalError("Inconsistency") }

        activeSessionObjects = ActiveSessionObjects(
            session: session,
            builder: builder,
            paceAlertController: PaceAlertController(viewModel: viewModel),
            paceController: PaceController(viewModel: viewModel))

        log.info("Starting workout")
        return true
    }

    // MARK: - Private methods

    private func endWorkout() async -> WorkoutSummary? {
        log.info("Ending workout")

        guard let activeSessionObjects, let viewModel else {
            fatalError("Workout not active")
        }

        activeSessionObjects.session.end()

        do {
            try await activeSessionObjects.builder.endCollection(at: Date())
            try await activeSessionObjects.builder.finishWorkout()
        } catch {
            log.error("Failed to finish workout: \(error)")
        }

        self.viewModel = nil
        self.activeSessionObjects = nil

        return buildSummary(from: viewModel, elapsedTime: activeSessionObjects.builder.elapsedTime)
    }

    private func buildSummary(from viewModel: WorkoutViewModel, elapsedTime: TimeInterval) -> WorkoutSummary {
        let averagePace: Pace
        if let distance = viewModel.distance {
            let kilometers = distance.converted(to: .kilometers).value
            if kilometers == 0 {
                averagePace = Pace(secondsPerKilometer: 0)
            } else {
                let pace = Int(elapsedTime / kilometers)
                averagePace = Pace(secondsPerKilometer: pace)
            }
        } else {
            averagePace = Pace(secondsPerKilometer: 0)
        }

        let summary = WorkoutSummary(
            workoutType: viewModel.workoutType,
            distance: viewModel.distance ?? .init(value: 0, unit: .meters),
            elapsedTime: elapsedTime,
            averagePace: averagePace,
            targetPace: viewModel.targetPace)
        return summary
    }
}

extension WorkoutController: WorkoutViewModelDelegate {
    func workoutViewModelPauseWorkout() {
        guard let activeSessionObjects else { return }
        activeSessionObjects.session.pause()
    }

    func workoutViewModelResumeWorkout() {
        guard let activeSessionObjects else { return }
        activeSessionObjects.session.resume()
    }

    func workoutViewModelEndWorkout() async -> WorkoutSummary? {
        await endWorkout()
    }
}

extension WorkoutController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        log.debug("HKWorkoutSession changed state to \(toState)")
        DispatchQueue.main.async {
            switch toState {
            case .ended:
                self.viewModel?.isActive = false
            case .paused:
                self.viewModel?.isActive = false
            case .running:
                self.viewModel?.isActive = true
            default:
                break
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        log.error("Workout error: \(error)")
    }
}

extension WorkoutController: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let heartRateType = HKQuantityType(.heartRate)

        if collectedTypes.contains(distanceType) {
            let startDate = Date().addingTimeInterval(-30)
            let endDate = Date()
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])

            let statistics = workoutBuilder.statistics(for: distanceType)
            let totalDistanceMeters = statistics?.sumQuantity()?.doubleValue(for: .meter())

            let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                guard let samples = samples?.compactMap({ $0 as? HKQuantitySample }), samples.count > 0 else { return }

                DispatchQueue.main.async {
                    if self.activeSessionObjects?.paceController.isAuthorized == false {
                        // The HK pace is very imprecise, only use if CL is unauthorized.
                        let seconds = samples.map({ $0.endDate.timeIntervalSince($0.startDate) }).reduce(0, +)
                        let meters = samples.map({ $0.quantity.doubleValue(for: .meter()) }).reduce(0, +)
                        let metersPerSecond = meters / seconds
                        let pace = 1 / (metersPerSecond / 1000)
                        self.viewModel?.currentPace = Pace(secondsPerKilometer: Int(pace))
                    }

                    if let totalDistanceMeters {
                        self.viewModel?.distance = Measurement(value: totalDistanceMeters, unit: .meters)
                    }
                }
            }
            healthStore.execute(query)
        }

        if collectedTypes.contains(heartRateType) {
            let statistics = workoutBuilder.statistics(for: heartRateType)
            let quantity = statistics?.mostRecentQuantity()
            if let heartRate = quantity?.doubleValue(for: .hertz()) {
                DispatchQueue.main.async {
                    self.viewModel?.heartRate = Int(heartRate * 60.0)
                }
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }
}
