import Foundation

struct DiagSummary: Codable {
    struct Entry: Codable {
        let lat: Double
        let lon: Double
        let t: TimeInterval
    }

    var title: String = ""
    var startTime: Date = Date()
    var endTime: Date = Date()
    var entries: [Entry] = []
}
