import Foundation

enum Navigation: Hashable {
    case setup
    case settings
    case editTargetPace
    case summary(WorkoutSummary)
}
