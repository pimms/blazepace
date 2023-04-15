import Foundation
import HealthKit
import CoreLocation

class PermissionHelper: NSObject {
    static let shared = PermissionHelper()

    private let log = Log(name: "PermissionHelper")
    private let healthStore = HKHealthStore()
    private let locationManager = CLLocationManager()

    private var locationPermissionErrorHandler: (() -> Void)?

    func requestHealthKitPermissions(onError: @escaping (Error) -> Void) {
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKSeriesType.workoutType(),
        ]

        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKSeriesType.workoutRoute(),
            HKObjectType.activitySummaryType()
        ]

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

    func requestLocationPermission(onError: @escaping () -> Void) {
        locationPermissionErrorHandler = onError
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}

extension PermissionHelper: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            log.info("CoreLocation authorization status: always")
        case .authorizedWhenInUse:
            log.info("CoreLocation authorization status: when in use")
        case .denied:
            log.error("CoreLocation authorization status: denied")
            locationPermissionErrorHandler?()
        default:
            log.error("CoreLocation authorization status: unknown (\(manager.authorizationStatus))")
        }
    }
}
