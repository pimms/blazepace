import Foundation

struct TargetPace: Hashable {
    static var `default`: TargetPace {
        let basePace = UserDefaults.standard.integer(forKey: AppStorageKey.defaultPace)
        let range = UserDefaults.standard.integer(forKey: AppStorageKey.defaultPaceRange)
        return TargetPace(
            secondsPerKilometer: basePace == 0 ? 300 : basePace,
            range: range == 0 ? 15 : range)
    }

    let secondsPerKilometer: Int
    let range: Int

    var lowerBound: Int { secondsPerKilometer - range }
    var upperBound: Int { secondsPerKilometer + range }
}
