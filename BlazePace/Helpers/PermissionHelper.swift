import Foundation
import HealthKit

class PermissionHelper {
    static let shared = PermissionHelper()

    func requestHealthKitPermissions(onError: @escaping (Error) -> Void) {
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
        ]

        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        ]

        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                print("Successfully acquired HK permissions")
            } else {
                print("Failed to acquire HK permissions")
            }

            if let error {
                print("Failed to acquire HK permissions: \(error)")
                onError(error)
            }
        }
    }
}
