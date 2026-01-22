import AVFoundation
import UIKit

class AudioService: NSObject {
    static let shared = AudioService()
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            // "Duck Others" lowers background music volume while speaking
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure AudioSession: \(error)")
        }
    }
    
    func announce(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Default to English for now
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Ensure session is active before speaking (in case it was deactivated)
        // configureAudioSession() // Optional: Re-activate if needed aggressively
        
        synthesizer.speak(utterance)
    }
}
