import Foundation
import AVFoundation
import SwiftUI

class BeepAlertPlayer: AlertPlayer {
    private let avplayer = AVPlayer()

    @AppStorage(AppStorageKey.duckOthersOnAlert)
    private var duckOthersOnAlert: Bool = true

    private lazy var tooSlowItem = makeAVPlayerItem("alarm-slow")
    private lazy var tooFastItem = makeAVPlayerItem("alarm-fast")

    override func playAlert(_ alert: WorkoutViewModel.PaceAlert) {
        duckOthers(autoUnduck: true)

        switch alert {
        case .tooSlowAlert:
            avplayer.replaceCurrentItem(with: tooSlowItem)
            avplayer.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            avplayer.play()
        case .tooFastAlert:
            avplayer.replaceCurrentItem(with: tooFastItem)
            avplayer.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            avplayer.play()
        }
    }

    private func makeAVPlayerItem(_ fileName: String) -> AVPlayerItem {
        let url = Bundle.main.url(forResource: fileName, withExtension: "mp3")!
        return AVPlayerItem(url: url)
    }
}
