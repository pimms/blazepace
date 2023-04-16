import Foundation

struct PaceFormatter {
    static private let kmToMilesFactor: Double = 1.609344

    // Returns on the format "MM:ss"
    static func paceString(fromSecondsPerKilometer seconds: Int) -> String {
        let measurementAdjusted: Int
        switch MeasurementSystem.current {
        case .metric:
            measurementAdjusted = seconds
        case .freedomUnits🇺🇸🔫:
            measurementAdjusted = Int(Double(seconds) * kmToMilesFactor)
        }

        let min = measurementAdjusted / 60
        let sec = measurementAdjusted % 60
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
