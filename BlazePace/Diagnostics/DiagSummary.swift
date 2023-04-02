import Foundation

struct DiagSummary: Codable {
    struct Entry: Codable {
        let lat: Double
        let lon: Double
        let t: TimeInterval
    }

    let title: String
    let startTime: Date
    let endTime: Date
    var entries: [Entry]
}
