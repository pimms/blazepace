import Foundation
import AVFAudio
import SwiftUI

class SpeechAlertPlayer: NSObject, AlertPlayer {
    private let synthesizer = AVSpeechSynthesizer()
    private let voice = AVSpeechSynthesisVoice(language: "en-US")

    @AppStorage(AppStorageKey.duckOthersOnAlert)
    private var duckOthersOnAlert: Bool = true
    private var isDucking = false

    private lazy var tooSlowUtterance = makeUtterance(for: "Too slow.")
    private lazy var tooFastUtterance = makeUtterance(for: "Too fast.")

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func playAlert(_ alert: WorkoutViewModel.PaceAlert) {
        switch alert {
        case .tooSlowAlert:
            synthesizer.speak(tooSlowUtterance)
        case .tooFastAlert:
            synthesizer.speak(tooFastUtterance)
        }
    }

    private func makeUtterance(for string: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = 0.65
        utterance.volume = 1
        utterance.voice = voice
        return utterance
    }
}

extension SpeechAlertPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        if duckOthersOnAlert {
            isDucking = false
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isDucking {
            try? AVAudioSession.sharedInstance().setActive(false)
            isDucking = false
        }
    }
}
