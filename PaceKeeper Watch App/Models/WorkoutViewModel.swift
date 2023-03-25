import Foundation
import Combine

protocol WorkoutManaging {
    func pauseWorkout()
    func endWorkout()
}

protocol WorkoutViewModelDelegate: AnyObject {
    func workoutViewModelPauseWorkout()
    func workoutViewModelEndWorkout()
}

class WorkoutViewModel: ObservableObject {
    @Published var targetPace: TargetPace?
    @Published var currentPace: Pace?
    @Published var averagePace: Pace?
    @Published var heartRate: Int?
    @Published var distance: Measurement<UnitLength>?

    weak var delegate: WorkoutViewModelDelegate?

    private let log = Log(name: "WorkoutViewModel")
}

extension WorkoutViewModel: WorkoutManaging {
    func pauseWorkout() {
        delegate?.workoutViewModelPauseWorkout()
    }

    func endWorkout() {
        delegate?.workoutViewModelEndWorkout()
    }
}

extension WorkoutViewModel {
    enum PaceRelativeToTarget: Equatable {
        case tooSlow
        case tooFast
        case inRange
    }

    var paceRelativeToTarget: PaceRelativeToTarget {
        guard let targetPace, let currentPace else { return .tooSlow }

        if currentPace.secondsPerKilometer < targetPace.secondsPerKilometer - targetPace.range {
            return .tooFast
        } else if currentPace.secondsPerKilometer > targetPace.secondsPerKilometer + targetPace.range {
            return .tooSlow
        } else {
            return .inRange
        }
    }

    var isInTargetPace: Bool {
        return paceRelativeToTarget == .inRange
    }
}
