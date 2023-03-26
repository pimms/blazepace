import Foundation
import Combine

protocol WorkoutViewModelDelegate: AnyObject {
    func workoutViewModelPauseWorkout()
    func workoutViewModelResumeWorkout()
    func workoutViewModelEndWorkout()
}

class WorkoutViewModel: ObservableObject {
    @Published var targetPace: TargetPace?
    @Published var currentPace: Pace?
    @Published var heartRate: Int?
    @Published var distance: Measurement<UnitLength>?

    @Published var isActive: Bool = false

    weak var delegate: WorkoutViewModelDelegate?

    private let log = Log(name: "WorkoutViewModel")

    func pauseWorkout() {
        delegate?.workoutViewModelPauseWorkout()
    }

    func resumeWorkout() {
        delegate?.workoutViewModelResumeWorkout()
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
