import Foundation

enum PaceAlertType: String, CaseIterable, Identifiable, Hashable {
    var id: String { rawValue }

    case sine = "Sine wave"
    case speech = "Speech"
    case ding = "Ding"

    func makeAlertPlayer() -> AlertPlayer {
        switch self {
        case .sine:
            return SineAlertPlayer()
        case .speech:
            return SpeechAlertPlayer()
        case .ding:
            return DingAlertPlayer()
        }
    }
}
