import Foundation
import SwiftUI
import Combine
import WatchKit

class PaceAlertController {

    private let log = Log(name: "PaceAlertController")
    private let viewModel: WorkoutViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var timer: Timer?

    @AppStorage(AppStorageKey.paceAlertInterval)
    private var paceNotificationInterval: TimeInterval = 5

    private var paceAlertType: PaceAlertType = .sine
    private var paceAlertPlayer: AlertPlayer = SineAlertPlayer()

    init(viewModel: WorkoutViewModel) {
        self.viewModel = viewModel

        viewModel.$recentRollingAveragePace
            .compactMap(({ $0 }))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pace in
                self?.onPaceUpdated()
            })
            .store(in: &subscriptions)
    }

    private func onPaceUpdated() {
        // We already have a timer active. It will notify the user.
        if timer != nil { return }

        guard viewModel.isActive, viewModel.playNotifications else { return }

        if viewModel.currentPaceAlert != nil {
            triggerPaceNotification()
        }
    }

    private func triggerPaceNotification() {
        guard viewModel.isActive,
              viewModel.playNotifications,
              let paceAlert = viewModel.currentPaceAlert,
              paceAlert == viewModel.paceRelativeToTarget else {
            timer?.invalidate()
            timer = nil
            return
        }

        reloadPaceAlertType()
        paceAlertPlayer.playAlert(paceAlert)
        startTimer()
    }

    private func startTimer() {
        let interval = TimeInterval(paceNotificationInterval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.triggerPaceNotification()
        }
    }


    private func reloadPaceAlertType() {
        let paceAlertType: PaceAlertType
        if let stringValue = UserDefaults.standard.string(forKey: AppStorageKey.paceAlertType),
           let type = PaceAlertType(rawValue: stringValue) {
            paceAlertType = type
        } else {
            paceAlertType = .sine
        }

        if paceAlertType != self.paceAlertType {
            self.paceAlertType = paceAlertType
            paceAlertPlayer = paceAlertType.makeAlertPlayer()
        }
    }
}
