import Foundation
import CoreLocation
import HealthKit

class LocationController: NSObject {
    private struct Entry {
        let date: Date
        let pace: Double
    }

    let isAuthorized: Bool
    var onNewLocation: ((CLLocation) -> Void)?

    private let log = Log(name: "PaceController")
    private let coreLocationManager = CLLocationManager()
    private let viewModel: WorkoutViewModel
    private let routeBuilder: HKWorkoutRouteBuilder

    private var entries: [Entry] = []

    init(viewModel: WorkoutViewModel, healthStore: HKHealthStore) {
        self.viewModel = viewModel
        self.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)

        switch coreLocationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            log.info("Authorized")
            isAuthorized = true
        default:
            log.error("Unauthorized")
            isAuthorized = false
        }

        super.init()
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        coreLocationManager.delegate = self
        coreLocationManager.startUpdatingLocation()
    }

    // MARK: - Internal methods

    func saveRoute(to workout: HKWorkout) async throws {
        try await routeBuilder.finishRoute(with: workout, metadata: nil)
    }

    // MARK: - Private methods

    private func updatePace() {
        cleanEntries(ageThreshold: 15)

        let now = Date()
        let currentPace = pace(for: entries.filter({ now.timeIntervalSince($0.date) < 5 }))
        let rollingPace = pace(for: entries)

        DispatchQueue.main.async {
            self.viewModel.currentPace = currentPace
            self.viewModel.recentRollingAveragePace = rollingPace
        }
    }

    private func pace(for entries: [Entry]) -> Pace {
        let sum = entries.map({ $0.pace }).reduce(0, +)
        let pace: Double

        if entries.count > 0, sum > 0 {
            pace = sum / Double(entries.count)
        } else {
            pace = 0
        }

        return Pace(secondsPerKilometer: Int(pace))
    }

    private func cleanEntries(ageThreshold: TimeInterval) {
        let cutoff = Date().addingTimeInterval(-ageThreshold)
        var index = 0
        while index < entries.count && entries[index].date < cutoff {
            index += 1
        }

        entries = Array(entries[index...])
    }
}

extension LocationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let filtered = locations.filter({ location in
            return location.speed > 0 && location.speedAccuracy >= 0 && location.horizontalAccuracy <= 50
        })

        guard filtered.count > 0 else { return }

        for loc in filtered {
            onNewLocation?(loc)
        }

        if viewModel.isActive {
            routeBuilder.insertRouteData(filtered, completion: { success, error in
                if !success, let error {
                    self.log.error("Failed to insert route data: \(error)")
                }
            })
        }

        entries.append(contentsOf: filtered.map({
            let pace = 1 / ($0.speed / 1000)
            return Entry(date: $0.timestamp, pace: pace)
        }))

        updatePace()
    }
}
