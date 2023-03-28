import Foundation

enum PaceAlertType: String, CaseIterable, Identifiable, Hashable {
    var id: String { rawValue }

    case ding = "Ding"
    case speech = "Speech"
}
