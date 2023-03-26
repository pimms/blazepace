import Foundation
import HealthKit
import Combine

@MainActor
class WorkoutController: NSObject, ObservableObject {
    static let shared = WorkoutController()

    @Published var viewModel: WorkoutViewModel?

    private var paceAlertController: PaceAlertController?
    private var paceSmoother: PaceSmoother?
    private var paceSmootherSubscription: AnyCancellable?

    private let healthStore = HKHealthStore()
    private let log = Log(name: "WorkoutController")

    private enum State {
        case active(session: HKWorkoutSession, builder: HKLiveWorkoutBuilder)
        case inactive
    }

    private var state: State = .inactive

    private override init() {}

    // MARK: - Internal methods

    func startWorkout(_ startData: WorkoutStartData) async -> Bool {
        guard case .inactive = state else { fatalError("A workout is already active") }

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

        state = .active(session: session, builder: builder)
        await MainActor.run {
            let vm = WorkoutViewModel(workoutType: startData.workoutType, targetPace: startData.targetPace)
            vm.delegate = self
            self.paceAlertController = PaceAlertController(viewModel: vm)
            self.viewModel = vm
            viewModel?.delegate = self

            let smoother = PaceSmoother()
            paceSmootherSubscription = smoother.$smoothedPace.sink(receiveValue: { [weak viewModel] pace in
                viewModel?.currentPace = pace
            })

            self.paceSmoother = smoother
        }

        log.info("Starting workout")
        return true
    }

    // MARK: - Private methods

    private func endWorkout() async -> WorkoutSummary? {
        log.info("Ending workout")
        guard case .active(let session, let builder) = state, let viewModel else {
            fatalError("Workout not active")
        }

        session.end()
        do {
            try await builder.endCollection(at: Date())
            try await builder.finishWorkout()
        } catch {
            log.error("Failed to finish workout: \(error)")
        }

        paceAlertController = nil
        paceSmootherSubscription = nil
        paceSmoother = nil
        self.viewModel = nil
        state = .inactive

        return buildSummary(from: viewModel, elapsedTime: builder.elapsedTime)
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
        guard case .active(session: let session, builder: _) = state else { return }
        session.pause()
    }

    func workoutViewModelResumeWorkout() {
        guard case .active(session: let session, builder: _) = state else { return }
        session.resume()
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
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }

            DispatchQueue.main.async {
                switch quantityType {
                case HKQuantityType(.distanceWalkingRunning):
                    self.log.debug("Updating distance")

                    let statistics = workoutBuilder.statistics(for: quantityType)

                    if let meters = statistics?.sumQuantity()?.doubleValue(for: .meter()) {
                        self.viewModel?.distance = Measurement(value: meters, unit: .meters)
                    }

                    if let mostRecent = statistics?.mostRecentQuantity(),
                       let interval = statistics?.mostRecentQuantityDateInterval(),
                       interval.duration > 0 {
                        let distance = mostRecent.doubleValue(for: .meter())
                        self.paceSmoother?.addEntry(date: interval.end, deltaTime: interval.duration, distance: distance)
                    }
                case HKQuantityType(.heartRate):
                    self.log.debug("Updating HR")
                    let statistics = workoutBuilder.statistics(for: quantityType)
                    let quantity = statistics?.mostRecentQuantity()
                    if let heartRate = quantity?.doubleValue(for: .hertz()) {
                        self.viewModel?.heartRate = Int(heartRate * 60.0)
                    }
                default:
                    self.log.debug("Unhandled HKQuantityType: \(quantityType)")
                    break
                }
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }
}
