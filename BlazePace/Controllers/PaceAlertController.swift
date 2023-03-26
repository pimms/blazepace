import Foundation
import SwiftUI
import Combine
import WatchKit

class PaceAlertController {

    private let log = Log(name: "PaceAlertController")
    private let viewModel: WorkoutViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var timer: Timer?

    @AppStorage(AppStorageKey.paceNotificationInterval)
    private var paceNotificationInterval: Int = 2

    init(viewModel: WorkoutViewModel) {
        self.viewModel = viewModel

        log.debug("Pace notifications enabled at \(paceNotificationInterval)s interval")
        let interval = TimeInterval(paceNotificationInterval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.triggerPaceNotification()
        }
    }

    private func triggerPaceNotification() {
        guard viewModel.isActive, viewModel.playNotifications else { return }
        switch viewModel.paceRelativeToTarget {
        case .inRange:
            break
        case .tooSlow:
            WKInterfaceDevice.current().play(.directionDown)
        case .tooFast:
            WKInterfaceDevice.current().play(.directionUp)
        }
    }
}
