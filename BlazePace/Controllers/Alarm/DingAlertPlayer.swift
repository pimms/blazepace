import Foundation
import WatchKit
import AVFoundation
import SwiftUI

class DingAlertPlayer: AlertPlayer {
    @AppStorage(AppStorageKey.duckOthersOnAlert)
    private var duckOthersOnAlert: Bool = true

    func playAlert(_ alert: WorkoutViewModel.PaceAlert) {
        if duckOthersOnAlert {
            try? AVAudioSession.sharedInstance().setActive(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                try? AVAudioSession.sharedInstance().setActive(false)
            }
        }

        switch alert {
        case .tooSlowAlert:
            WKInterfaceDevice.current().play(.directionDown)
        case .tooFastAlert:
            WKInterfaceDevice.current().play(.directionUp)
        }
    }
}
