import Foundation
import SwiftUI
import Combine
import WatchKit

class PaceAlertController {

    private let log = Log(name: "PaceAlertController")
    private let viewModel: WorkoutViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var timer: Timer?
    private lazy var speechSynthesizer = SpeechSynthesizer()

    @AppStorage(AppStorageKey.paceAlertInterval)
    private var paceNotificationInterval: Int = 2

    private var paceAlertType: PaceAlertType {
        if let stringValue = UserDefaults.standard.string(forKey: AppStorageKey.paceAlertType),
           let paceAlertType = PaceAlertType(rawValue: stringValue) {
            return paceAlertType
        }
        return .ding
    }

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
            switch paceAlertType {
            case .ding:
                WKInterfaceDevice.current().play(.directionDown)
            case .speech:
                speechSynthesizer.speak("Too slow.")
            }
        case .tooFast:
            switch paceAlertType {
            case .ding:
                WKInterfaceDevice.current().play(.directionUp)
            case .speech:
                speechSynthesizer.speak("Too fast.")
            }
        }
    }
}
