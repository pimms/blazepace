import Foundation

enum PaceAlertType: String, CaseIterable, Identifiable, Hashable {
    var id: String { rawValue }

    case beep = "Beep"
    case speech = "Speech"
    case ding = "Ding"

    func makeAlertPlayer() -> AlertPlayer {
        switch self {
        case .beep:
            return BeepAlertPlayer()
        case .speech:
            return SpeechAlertPlayer()
        case .ding:
            return DingAlertPlayer()
        }
    }
}
