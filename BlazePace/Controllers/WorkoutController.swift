import Foundation
import HealthKit
import Combine

@MainActor
class WorkoutController: NSObject, ObservableObject {
    private struct ActiveSessionObjects {
        let session: HKWorkoutSession
        let builder: HKLiveWorkoutBuilder
        let paceAlertController: PaceAlertController
        let locationController: LocationController
        let diagBuilder: DiagBuilder
    }

    static let shared = WorkoutController()

    @Published var viewModel: WorkoutViewModel?

    private let healthStore = HKHealthStore()
    private let log = Log(name: "WorkoutController")
    private var activeSessionObjects: ActiveSessionObjects?

    private override init() {}

    // MARK: - Internal methods

    func restoreWorkoutSession() async {
        let session = try? await healthStore.recoverActiveWorkoutSession()
        guard let session else { return }

        self.log.error("Recovering previous session")

        if await self.startWorkout(with: session) {
            self.log.error("Successfully restored prior session")
        } else {
            self.log.error("Failed to recover prior session")
        }
    }

    func startWorkout(_ startData: WorkoutStartData) async -> Bool {
        guard activeSessionObjects == nil else { fatalError("A workout is already active") }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = startData.workoutType.healthKitType
        configuration.locationType = .outdoor

        let session: HKWorkoutSession
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)

            let startDate = Date()
            session.startActivity(with: startDate)

            let builder = session.associatedWorkoutBuilder()
            try await builder.beginCollection(at: startDate)
            builder.startData = startData
        } catch {
            log.error("Failed to start workout: \(error)")
            return false
        }
        log.info("Workout setup OK")

        return await startWorkout(with: session)
    }

    // MARK: - Private methods

    private func startWorkout(with session: HKWorkoutSession) async -> Bool {
        let builder = session.associatedWorkoutBuilder()
        let startData = builder.startData

        session.delegate = self
        builder.delegate = self
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: session.workoutConfiguration)

        await MainActor.run {
            viewModel = WorkoutViewModel(
                workoutType: startData.workoutType,
                startDate: builder.startDate ?? Date(),
                targetPace: startData.targetPace)
            viewModel?.isActive = true
            viewModel?.delegate = self
        }

        guard let viewModel else { fatalError("Inconsistency") }

        let diagBuilder = DiagBuilder()

        activeSessionObjects = ActiveSessionObjects(
            session: session,
            builder: builder,
            paceAlertController: PaceAlertController(viewModel: viewModel),
            locationController: LocationController(viewModel: viewModel, healthStore: healthStore),
            diagBuilder: diagBuilder)

        activeSessionObjects?.locationController.onNewLocation = diagBuilder.addLocation

        viewModel.isActive = true
        log.info("Starting workout")
        return true
    }

    private func endWorkout() async -> WorkoutSummary? {
        log.info("Ending workout")

        guard let activeSessionObjects, let viewModel else {
            fatalError("Workout not active")
        }

        activeSessionObjects.session.end()

        do {
            try await activeSessionObjects.builder.endCollection(at: Date())
            if let workout = try await activeSessionObjects.builder.finishWorkout() {
                try await activeSessionObjects.locationController.saveRoute(to: workout)
            } else {
                log.error("Failed to retrieve HKWorkout from workout builder")
            }
        } catch {
            log.error("Failed to finish workout: \(error)")
        }

        self.viewModel = nil
        self.activeSessionObjects = nil

        let summary = buildSummary(from: viewModel, elapsedTime: activeSessionObjects.builder.elapsedTime)
        activeSessionObjects.diagBuilder.finalize(with: summary)
        return summary
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
                    if self.activeSessionObjects?.locationController.isAuthorized == false {
                        // The HK pace is very imprecise, only use if CL is unauthorized.
                        let seconds = samples.map({ $0.endDate.timeIntervalSince($0.startDate) }).reduce(0, +)
                        let meters = samples.map({ $0.quantity.doubleValue(for: .meter()) }).reduce(0, +)
                        let metersPerSecond = meters / seconds
                        let pace = 1 / (metersPerSecond / 1000)
                        self.viewModel?.currentPace = Pace(secondsPerKilometer: Int(pace))
                        self.viewModel?.recentRollingAveragePace = Pace(secondsPerKilometer: Int(pace))
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
                    self.viewModel?.lastHeartrateUpdate = Date()
                    self.viewModel?.heartRate = Int(heartRate * 60.0)
                }
            }
        } else if let lastHeartRateUpdate = viewModel?.lastHeartrateUpdate, Date().timeIntervalSince(lastHeartRateUpdate) > 5 {
            DispatchQueue.main.async {
                self.viewModel?.lastHeartrateUpdate = nil
                self.viewModel?.heartRate = nil
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }
}
