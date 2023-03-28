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

        viewModel.$currentPace
            .compactMap(({ $0 }))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pace in
                self?.onPaceUpdated(pace)
            })
            .store(in: &subscriptions)
    }

    private func onPaceUpdated(_ pace: Pace) {
        // We already have a timer active. It will notify the user.
        if timer != nil { return }

        guard viewModel.isActive, viewModel.playNotifications else { return }
        switch viewModel.paceRelativeToTarget {
        case .inRange:
            break
        case .tooSlow, .tooFast:
            triggerPaceNotification()
        }
    }

    private func triggerPaceNotification() {
        guard viewModel.isActive, viewModel.playNotifications else { return }
        switch viewModel.paceRelativeToTarget {
        case .inRange:
            timer?.invalidate()
            timer = nil
        case .tooSlow:
            switch paceAlertType {
            case .ding:
                WKInterfaceDevice.current().play(.directionDown)
            case .speech:
                speechSynthesizer.speak("Too slow.")
            }
            startTimer()
        case .tooFast:
            switch paceAlertType {
            case .ding:
                WKInterfaceDevice.current().play(.directionUp)
            case .speech:
                speechSynthesizer.speak("Too fast.")
            }
            startTimer()
        }
    }

    private func startTimer() {
        let interval = TimeInterval(paceNotificationInterval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.triggerPaceNotification()
        }
    }
}
