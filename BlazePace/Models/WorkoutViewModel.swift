import Foundation
import Combine

protocol WorkoutViewModelDelegate: AnyObject {
    func workoutViewModelPauseWorkout()
    func workoutViewModelResumeWorkout()
    func workoutViewModelEndWorkout() async -> WorkoutSummary?
}

class WorkoutViewModel: ObservableObject {
    let workoutType: WorkoutType
    let startDate: Date
    var lastHeartrateUpdate: Date?

    @Published var targetPace: TargetPace
    @Published var currentPace: Pace?
    @Published var heartRate: Int?
    @Published var distance: Measurement<UnitLength>?
    @Published var isActive: Bool = false
    @Published var playNotifications: Bool = true

    weak var delegate: WorkoutViewModelDelegate?

    private let log = Log(name: "WorkoutViewModel")

    init(workoutType: WorkoutType, startDate: Date, targetPace: TargetPace) {
        self.workoutType = workoutType
        self.startDate = startDate
        self._targetPace = .init(initialValue: targetPace)
    }

    func pauseWorkout() {
        delegate?.workoutViewModelPauseWorkout()
    }

    func resumeWorkout() {
        delegate?.workoutViewModelResumeWorkout()
    }

    func endWorkout() async -> WorkoutSummary? {
        await delegate?.workoutViewModelEndWorkout()
    }
}

extension WorkoutViewModel {
    enum PaceRelativeToTarget: Equatable {
        case tooSlow
        case tooFast
        case inRange
    }

    var paceRelativeToTarget: PaceRelativeToTarget {
        guard let currentPace else { return .tooSlow }

        if currentPace.secondsPerKilometer < targetPace.lowerBound {
            return .tooFast
        } else if currentPace.secondsPerKilometer > targetPace.upperBound {
            return .tooSlow
        } else {
            return .inRange
        }
    }

    var isInTargetPace: Bool {
        return paceRelativeToTarget == .inRange
    }
}
