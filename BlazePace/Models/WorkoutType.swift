import Foundation
import HealthKit

enum WorkoutType: String, Hashable, Codable {
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
