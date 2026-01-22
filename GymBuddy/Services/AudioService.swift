import AVFoundation
import UIKit

class AudioService: NSObject {
    static let shared = AudioService()
    private let synthesizer = AVSpeechSynthesizer()
    private var premiumVoice: AVSpeechSynthesisVoice?

    // MARK: - Motivational Phrases

    // MARK: - Motivational Phrases

    private let setStartPhrases = [
        "Let's crush this set!",
        "Focus. Power.",
        "Light weight, baby!",
        "Own this set!",
        "Strong form, let's go.",
        "Make it look easy.",
        "Full range of motion.",
        "Drive through!",
        "Show me what you got!"
    ]

    private let restEndPhrases = [
        "Time to work!",
        "Get ready.",
        "Back under the bar.",
        "Let's get it.",
        "Round two, fight!",
        "Focus mode: On.",
        "Next set starts now."
    ]

    private let setCompletedPhrases = [
        "Good set. Rest up.",
        "Nice work. Catch your breath.",
        "Solid. Take a break.",
        "Easy money. Rest now.",
        "Strong effort. Relax.",
        "Done. Recover."
    ]

    private let workoutCompletePhrases = [
        "Workout destroyed! excellent job.",
        "You survived! Great session.",
        "Victory! See you next time.",
        "Session complete. Go eat.",
        "Stronger than yesterday. Good job."
    ]

    override init() {
        super.init()
        configureAudioSession()
        configurePremiumVoice()
    }

    private func configureAudioSession() {
        do {
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

    private func configurePremiumVoice() {
        // Try to find a premium/enhanced voice for more natural speech
        let preferredVoiceIdentifiers = [
            "com.apple.voice.premium.en-US.Zoe",
            "com.apple.voice.enhanced.en-US.Zoe",
            "com.apple.voice.premium.en-US.Samantha",
            "com.apple.voice.enhanced.en-US.Samantha",
            "com.apple.voice.premium.en-US.Evan",
            "com.apple.voice.enhanced.en-US.Evan"
        ]

        for identifier in preferredVoiceIdentifiers {
            if let voice = AVSpeechSynthesisVoice(identifier: identifier) {
                premiumVoice = voice
                print("Using premium voice: \(identifier)")
                return
            }
        }

        // Fallback to best available en-US voice
        premiumVoice = AVSpeechSynthesisVoice(language: "en-US")
        print("Using default en-US voice")
    }

    // MARK: - Basic Announce

    func announce(_ text: String, rate: Float = 0.52) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = premiumVoice
        utterance.rate = rate
        utterance.pitchMultiplier = 1.05  // Slightly higher pitch for energy
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1

        synthesizer.speak(utterance)
    }

    // MARK: - Coach Calls (Randomized Motivation)

    /// Called when a new set is about to start (e.g. after rest)
    func announceSetStart() {
        let phrase = restEndPhrases.randomElement() ?? "Let's work."
        announce(phrase, rate: 0.55)
    }

    /// Called when rest ends
    func announceRestEnd() {
        // This effectively starts the set
        announceSetStart()
    }

    /// Called when workout is complete
    func announceWorkoutComplete() {
        let phrase = workoutCompletePhrases.randomElement() ?? "Workout complete!"
        announce(phrase, rate: 0.5)
    }

    /// Announce exercise with motivation
    func announceExercise(_ name: String) {
        announce("Next up: \(name). Get ready.", rate: 0.52)
    }

    /// Countdown announcement
    func announceCountdown(_ number: Int) {
        announce("\(number)", rate: 0.6)
    }

    /// Announce set completed / start resting
    func announceSetCompleted() {
        let phrase = setCompletedPhrases.randomElement() ?? "Rest."
        announce(phrase, rate: 0.53)
    }

    /// Announce workout start
    func announceWorkoutStart(planName: String, firstExercise: String) {
        announce("Starting \(planName). First up: \(firstExercise). Let's do this.", rate: 0.5)
    }
}
