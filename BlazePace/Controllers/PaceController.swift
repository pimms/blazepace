import Foundation
import CoreLocation

class PaceController: NSObject {
    let isAuthorized: Bool

    private let log = Log(name: "PaceController")
    private let coreLocationManager = CLLocationManager()
    private let viewModel: WorkoutViewModel

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
}

extension PaceController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Received locations: \(locations.count)")
    }
}
