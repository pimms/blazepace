import Foundation
import HealthKit

enum WorkoutType: String, Hashable {
    static var `default`: WorkoutType {
        if let rawValue = UserDefaults.standard.string(forKey: AppStorageKey.defaultWorkoutType),
           let workoutType = WorkoutType(rawValue: rawValue) {
            return workoutType
        }

        return .running
    }

    case running = "Running"
    case walking = "Walking"

    var healthKitType: HKWorkoutActivityType {
        switch self {
        case .running:
            return .running
        case .walking:
            return .walking
        }
    }
}
