import Foundation
import HealthKit
import CoreLocation
import SwiftUI

class PermissionHelper: NSObject {
    private let log = Log(name: "PermissionHelper")
    private let healthStore = HKHealthStore()
    private let locationManager = CLLocationManager()

    private var locationPermissionClosure: ((Bool) -> Void)?

    @AppStorage(AppStorageKey.hasRequestedLocationPermission)
    private var hasRequestedLocationPermission = false

    func requestHealthKitPermissions() async -> Bool {
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
            HKSeriesType.workoutType(),
            HKObjectType.activitySummaryType()
        ]

        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                if success {
                    self.log.debug("Successfully acquired HK permissions")
                } else {
                    self.log.error("Failed to acquire HK permissions")
                }

                if let error {
                    self.log.error("Failed to acquire HK permissions: \(error)")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }

    func requestLocationPermission() async -> Bool {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            break
        }

        return await withCheckedContinuation { continuation in
            if hasRequestedLocationPermission {
                // If we have already requested location permission, we are under watchOS' mercy
                // of when the user will be prompted again. Assume that the dialog won't be shown.
                continuation.resume(returning: false)
            } else {
                locationPermissionClosure = { result in
                    continuation.resume(returning: result)
                }
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            hasRequestedLocationPermission = true
        }
    }
}

extension PermissionHelper: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            log.info("CoreLocation authorization status: always")
            locationPermissionClosure?(true)
        case .authorizedWhenInUse:
            log.info("CoreLocation authorization status: when in use")
            locationPermissionClosure?(true)
        case .denied:
            log.error("CoreLocation authorization status: denied")
            locationPermissionClosure?(false)
        default:
            log.error("CoreLocation authorization status: unknown (\(manager.authorizationStatus))")
            locationPermissionClosure?(false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("wtf")
    }
}
