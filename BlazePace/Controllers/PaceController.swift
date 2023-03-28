import Foundation
import CoreLocation

class PaceController: NSObject {
    private struct Entry {
        let date: Date
        let pace: Double
    }

    let isAuthorized: Bool

    private let log = Log(name: "PaceController")
    private let coreLocationManager = CLLocationManager()
    private let viewModel: WorkoutViewModel

    private var entries: [Entry] = []

    init(viewModel: WorkoutViewModel) {
        self.viewModel = viewModel
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

    private func updatePace() {
        cleanEntries()

        let sum = entries.map({ $0.pace }).reduce(0, +)
        let pace: Double

        if entries.count > 0, sum > 0 {
            pace = sum / Double(entries.count)
        } else {
            pace = 0
        }

        DispatchQueue.main.async {
            self.viewModel.currentPace = Pace(secondsPerKilometer: Int(pace))
        }
    }

    private func cleanEntries() {
        let cutoff = Date().addingTimeInterval(-10)
        var index = 0
        while index < entries.count && entries[index].date < cutoff {
            index += 1
        }

        entries = Array(entries[index...])
    }
}

extension PaceController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.speed >= 0 else { return }

        let pace = 1 / (location.speed / 1000)
        let entry = Entry(date: Date(), pace: pace)
        entries.append(entry)

        updatePace()
    }
}
