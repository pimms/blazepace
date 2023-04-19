import Foundation
import AVFoundation
import SwiftUI

class AVHelper {
    @AppStorage(AppStorageKey.duckOthersOnAlert)
    private static var duckOtherAudio = true
    private static var log = Log(name: "AVHelper")

    static func airPlayConnected() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute

        // There are a million (not really) different output types, but assume
        // that the user has headphones connected if we find **ONE** output that
        // is NOT the built-in speaker
        return route.outputs.contains(where: { $0.portType != .builtInSpeaker })
    }

    static func updateAudioCategory() {
        if duckOtherAudio {
            log.info("Audio category: duckOthers 🦆")
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
        } else {
            log.info("Audio category: mixWithOthers 💃🕺")
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        }

        unduckOthers()
    }

    static func duckOthers() {
        log.debug("Activating session")
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    static func unduckOthers() {
        log.debug("Deactivating session")
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
