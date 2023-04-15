import Foundation
import AVFAudio

class SpeechSynthesizer: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    private let voice = AVSpeechSynthesisVoice(language: "en-GB")

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = 0.65
        utterance.volume = 1
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
