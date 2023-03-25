import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var targetPace: TargetPace?
    @Published var currentPace: Pace?
    @Published var averagePace: Pace?
    @Published var heartRate: Int?
    @Published var distance: Measurement<UnitLength>?
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
