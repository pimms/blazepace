import Foundation
import SwiftUI

struct TargetPace: Hashable {
    static var `default`: TargetPace {
        let basePace = UserDefaults.standard.integer(forKey: AppStorageKey.defaultPace)
        let range = UserDefaults.standard.integer(forKey: AppStorageKey.defaultPaceRange)
        return TargetPace(
            secondsPerKilometer: basePace == 0 ? 300 : basePace,
            range: range == 0 ? 15 : range)
    }

    // MARK: - Static

    static let paceIncrement = 5
    static let minValue = 120
    static let maxValue = 1200

    // MARK: - Properties

    let secondsPerKilometer: Int
    let range: Int

    var lowerBound: Int { secondsPerKilometer - range }
    var upperBound: Int { secondsPerKilometer + range }

    // MARK: - Init

    init(secondsPerKilometer: Int, range: Int) {
        if secondsPerKilometer < Self.minValue {
            self.secondsPerKilometer = Self.minValue
        } else if secondsPerKilometer > Self.maxValue {
            self.secondsPerKilometer = Self.maxValue
        } else {
            self.secondsPerKilometer = secondsPerKilometer
        }

        self.range = range
    }
}
