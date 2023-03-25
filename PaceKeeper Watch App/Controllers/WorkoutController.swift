import Foundation
import HealthKit

class WorkoutController: NSObject, ObservableObject {
    static let shared = WorkoutController()

    private let healthStore = HKHealthStore()
    private let log = Log(name: "WorkoutController")

    private enum State {
        case active(session: HKWorkoutSession, builder: HKLiveWorkoutBuilder)
        case inactive
    }

    private var state: State = .inactive

    private override init() {}

    func startWorkout() async -> Bool {
        guard case .inactive = state else { fatalError("A workout is already active") }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
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

        state = .active(session: session, builder: builder)
        return true
    }

    func endWorkout() async {
        guard case .active(let session, let builder) = state else {
            fatalError("Workout not active")
        }

        session.end()
        do {
            try await builder.endCollection(at: Date())
            try await builder.finishWorkout()
        } catch {
            log.error("Failed to finish workout: \(error)")
        }

        state = .inactive
    }
}

extension WorkoutController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        log.debug("HKWorkoutSession changed state to \(toState)")
        switch toState {
        case .ended:
            log.info("TODO: Handle ended session")
        case .paused:
            log.info("TODO: Handle paused session")
        case .running:
            log.info("TODO: Handle active session")
        default:
            break
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        log.info("TODO: Handle failed session")
    }
}

extension WorkoutController: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }

            let statistics = workoutBuilder.statistics(for: quantityType)
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }
}
