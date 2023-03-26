import Foundation

struct PaceFormatter {
    // Returns on the format "MM:ss"
    static func minuteString(fromSeconds seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return "\(min):\(sec < 10 ? "0" : "")\(sec)"
    }

    static func durationString(from duration: Int) -> String {
        let hours = duration / 3600
        let mins = (duration % 3600) / 60
        let secs = duration % 60

        var result: String = ""

        if hours != 0 {
            result += "\(hours):"
        }

        if mins == 0 {
            result += "00:"
        } else {
            result += "\(mins < 10 ? "0" : "")\(mins):"
        }

        result += "\(secs < 10 ? "0" : "")\(secs)"
        return result
    }
}
