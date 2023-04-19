import Foundation
import AVFoundation
import SwiftUI

class AlertPlayer: NSObject {
    @AppStorage(AppStorageKey.duckOthersOnAlert)
    private var duckOthersOnAlert: Bool = true
    private var isDucking = false

    deinit {
        unduckOthers()
    }

    func playAlert(_ alert: WorkoutViewModel.PaceAlert) {
        fatalError("\(#function) not overridden")
    }

    func duckOthers(autoUnduck: Bool) {
        if duckOthersOnAlert {
            isDucking = true
            AVHelper.duckOthers()

            if autoUnduck {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.unduckOthers()
                }
            }
        }
    }

    func unduckOthers() {
        if isDucking {
            AVHelper.unduckOthers()
            isDucking = false
        }
    }
}
