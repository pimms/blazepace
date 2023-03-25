import Foundation

struct PaceFormatter {
    static func minuteString(fromSeconds seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return "\(min):\(sec < 10 ? "0" : "")\(sec)"
    }
}
