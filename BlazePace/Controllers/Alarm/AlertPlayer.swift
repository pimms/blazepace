import Foundation
import AVFoundation
import SwiftUI

class AlertPlayer: NSObject {
    @AppStorage(AppStorageKey.duckOthersOnAlert)
    private var duckOthersOnAlert: Bool = true
    private var isDucking = false

    deinit {
        if isDucking {
            print("------ WOULD HAVE FUCKED UP -------")
        }
        unduckOthers()
    }

    func playAlert(_ alert: WorkoutViewModel.PaceAlert) {
        fatalError("\(#function) not overridden")
    }

    func duckOthers(autoUnduck: Bool) {
        if duckOthersOnAlert {
            isDucking = true
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    }

    func unduckOthers() {
        if isDucking {
            try? AVAudioSession.sharedInstance().setActive(false)
            isDucking = false
        }
    }
}
