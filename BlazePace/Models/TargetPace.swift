import Foundation

struct TargetPace {
    let secondsPerKilometer: Int
    let range: Int

    var lowerBound: Int { secondsPerKilometer - range }
    var upperBound: Int { secondsPerKilometer + range }
}
