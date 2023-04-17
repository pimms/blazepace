import Foundation

enum Navigation: Hashable {
    case setup
    case settings(SettingsView.Context)
    case editTargetPace
    case summary(WorkoutSummary)
}
