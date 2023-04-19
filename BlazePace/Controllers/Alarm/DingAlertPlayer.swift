import Foundation
import WatchKit
import AVFoundation
import SwiftUI

class DingAlertPlayer: AlertPlayer {
    override func playAlert(_ alert: WorkoutViewModel.PaceAlert) {
        duckOthers(autoUnduck: true)

        switch alert {
        case .tooSlowAlert:
            WKInterfaceDevice.current().play(.directionDown)
        case .tooFastAlert:
            WKInterfaceDevice.current().play(.directionUp)
        }
    }
}
