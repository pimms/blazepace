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
    @Published var recentRollingAveragePace: Pace?
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

    enum PaceAlert: Equatable {
        case tooSlowAlert
        case tooFastAlert

        static func == (lhs: Self, rhs: PaceRelativeToTarget) -> Bool {
            switch (lhs, rhs) {
            case (.tooSlowAlert, .tooSlow):
                return true
            case (.tooFastAlert, .tooFast):
                return true
            default:
                return false
            }
        }
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

    var currentPaceAlert: PaceAlert? {
        guard let recentRollingAveragePace else { return nil }
        guard let currentPace else { return nil }

        if currentPace.secondsPerKilometer > 1800 {
            return nil
        }

        if recentRollingAveragePace.secondsPerKilometer < targetPace.lowerBound && currentPace.secondsPerKilometer < targetPace.lowerBound {
            return .tooFastAlert
        } else if recentRollingAveragePace.secondsPerKilometer > targetPace.upperBound && currentPace.secondsPerKilometer > targetPace.upperBound {
            return .tooSlowAlert
        } else {
            return nil
        }
    }

    var isInTargetPace: Bool {
        return paceRelativeToTarget == .inRange
    }
}
