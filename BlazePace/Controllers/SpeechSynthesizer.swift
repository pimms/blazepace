import Foundation
import AVFAudio

class SpeechSynthesizer {
    private let synthesizer = AVSpeechSynthesizer()
    private let voice = AVSpeechSynthesisVoice(language: "en-GB")

    func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
        // utterance.rate = 0.57
        // utterance.pitchMultiplier = 0.8
        // utterance.postUtteranceDelay = 0.2
        // utterance.volume = 0.8
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
}