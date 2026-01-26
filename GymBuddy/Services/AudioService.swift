import AVFoundation
import UIKit

class AudioService: NSObject {
    static let shared = AudioService()
    private let synthesizer = AVSpeechSynthesizer()
    private var cachedVoice: AVSpeechSynthesisVoice?
    private var cachedLanguage: AppLanguage?

    // MARK: - Phrase History (prevents repetition)

    private var phraseHistory: [PhraseCategory: [String]] = [:]
    private let maxHistorySize = 3

    private enum PhraseCategory {
        case setStart
        case setComplete
        case restEnd
        case workoutComplete
        case motivationTip
    }

    // MARK: - Motivational Phrases (English)

    private let setStartPhrasesEN = [
        "Let's crush this set!",
        "Focus. Power.",
        "Light weight, baby!",
        "Own this set!",
        "Strong form, let's go.",
        "Make it look easy.",
        "Full range of motion.",
        "Drive through!",
        "Show me what you got!",
        "Time to shine.",
        "You've got this."
    ]

    private let restEndPhrasesEN = [
        "Time to work!",
        "Get ready.",
        "Back under the bar.",
        "Let's get it.",
        "Round two, fight!",
        "Focus mode: On.",
        "Next set starts now.",
        "Here we go.",
        "Lock in."
    ]

    private let setCompletedPhrasesEN = [
        "Good set. Rest up.",
        "Nice work. Catch your breath.",
        "Solid. Take a break.",
        "Easy money. Rest now.",
        "Strong effort. Relax.",
        "Done. Recover.",
        "Clean reps. Rest.",
        "That's how it's done."
    ]

    private let workoutCompletePhrasesEN = [
        "Workout destroyed! Excellent job.",
        "You survived! Great session.",
        "Victory! See you next time.",
        "Session complete. Go eat.",
        "Stronger than yesterday. Good job.",
        "Another one in the books.",
        "Beast mode complete."
    ]

    private let motivationTipsEN = [
        "Remember to breathe.",
        "Stay hydrated.",
        "Control the negative.",
        "Mind-muscle connection.",
        "Quality over quantity."
    ]

    // MARK: - Motivational Phrases (German)

    private let setStartPhrasesDE = [
        "Auf geht's!",
        "Fokus. Kraft.",
        "Leichtes Gewicht!",
        "Der Satz gehört dir!",
        "Saubere Form, los!",
        "Zeig was du kannst.",
        "Volle Bewegung.",
        "Durchziehen!",
        "Gib alles!",
        "Jetzt wird's ernst.",
        "Du schaffst das."
    ]

    private let restEndPhrasesDE = [
        "Zeit zu arbeiten!",
        "Mach dich bereit.",
        "Zurück ans Eisen.",
        "Los geht's.",
        "Runde zwei!",
        "Fokus an.",
        "Nächster Satz.",
        "Auf geht's.",
        "Konzentration."
    ]

    private let setCompletedPhrasesDE = [
        "Guter Satz. Pause.",
        "Stark gemacht. Durchatmen.",
        "Solide. Kurze Pause.",
        "Sauber. Erhol dich.",
        "Starke Leistung. Ruhe.",
        "Fertig. Regenerieren.",
        "Saubere Wiederholungen.",
        "Genau so."
    ]

    private let workoutCompletePhrasesDE = [
        "Workout erledigt! Super gemacht.",
        "Überlebt! Starke Session.",
        "Geschafft! Bis zum nächsten Mal.",
        "Training komplett. Ab zum Essen.",
        "Stärker als gestern. Gut gemacht.",
        "Wieder eins geschafft.",
        "Beast Mode beendet."
    ]

    private let motivationTipsDE = [
        "Denk ans Atmen.",
        "Trink genug Wasser.",
        "Kontrolliere die Bewegung.",
        "Spür den Muskel.",
        "Qualität vor Quantität."
    ]

    // MARK: - Premium Voice Identifiers
    // Priority order: Premium > Enhanced > Standard
    // These voices must be downloaded by the user in iOS Settings > Accessibility > Spoken Content

    private let englishVoicePriority = [
        "com.apple.voice.premium.en-US.Zoe",
        "com.apple.voice.enhanced.en-US.Zoe",
        "com.apple.voice.premium.en-US.Ava",
        "com.apple.voice.enhanced.en-US.Ava",
        "com.apple.voice.premium.en-US.Samantha",
        "com.apple.voice.enhanced.en-US.Samantha",
        "com.apple.voice.premium.en-US.Evan",
        "com.apple.voice.enhanced.en-US.Evan"
    ]

    private let germanVoicePriority = [
        "com.apple.voice.premium.de-DE.Anna",
        "com.apple.voice.enhanced.de-DE.Anna",
        "com.apple.voice.premium.de-DE.Petra",
        "com.apple.voice.enhanced.de-DE.Petra",
        "com.apple.voice.premium.de-DE.Markus",
        "com.apple.voice.enhanced.de-DE.Markus"
    ]

    // MARK: - Initialization

    override init() {
        super.init()
        configureAudioSession()
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
            print("AudioService: Failed to configure AudioSession: \(error)")
        }
    }

    // MARK: - Voice Selection

    /// Returns the best available voice based on current language setting
    private func getBestVoice() -> AVSpeechSynthesisVoice? {
        let settings = AppSettings.shared

        // Check if user has a preferred voice set
        if let preferredId = settings.preferredVoiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: preferredId) {
            return voice
        }

        // Use cached voice if language hasn't changed
        if let cached = cachedVoice, cachedLanguage == settings.appLanguage {
            return cached
        }

        // Find best voice for current language
        let priorityList = settings.appLanguage == .german ? germanVoicePriority : englishVoicePriority
        let fallbackLanguage = settings.appLanguage == .german ? "de-DE" : "en-US"

        for identifier in priorityList {
            if let voice = AVSpeechSynthesisVoice(identifier: identifier) {
                cachedVoice = voice
                cachedLanguage = settings.appLanguage
                print("AudioService: Using premium voice: \(voice.name)")
                return voice
            }
        }

        // Fallback to default system voice for language
        let fallbackVoice = AVSpeechSynthesisVoice(language: fallbackLanguage)
        cachedVoice = fallbackVoice
        cachedLanguage = settings.appLanguage
        print("AudioService: Using fallback voice for \(fallbackLanguage)")
        return fallbackVoice
    }

    /// Clears voice cache (call when language setting changes)
    func invalidateVoiceCache() {
        cachedVoice = nil
        cachedLanguage = nil
    }

    // MARK: - Phrase Selection (with history to prevent repetition)

    private func selectPhrase(from phrases: [String], category: PhraseCategory) -> String {
        var history = phraseHistory[category] ?? []

        // Filter out recently used phrases
        let available = phrases.filter { !history.contains($0) }

        // If all phrases were used recently, reset history
        let pool = available.isEmpty ? phrases : available

        guard let selected = pool.randomElement() else {
            return phrases.first ?? ""
        }

        // Update history
        history.append(selected)
        if history.count > maxHistorySize {
            history.removeFirst()
        }
        phraseHistory[category] = history

        return selected
    }

    // MARK: - Basic Announce

    func announce(_ text: String, rate: Float = 0.52) {
        guard AppSettings.shared.isVoiceEnabled else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getBestVoice()

        // Optimized parameters for motivating coach voice
        utterance.rate = rate
        utterance.pitchMultiplier = 1.08  // Slightly elevated for energy
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.1

        synthesizer.speak(utterance)
    }

    // MARK: - Verbosity Helpers

    private var verbosity: CoachVerbosity {
        AppSettings.shared.coachVerbosity
    }

    private var isGerman: Bool {
        AppSettings.shared.appLanguage == .german
    }

    // MARK: - Coach Calls

    /// Called when workout starts
    func announceWorkoutStart(planName: String, firstExercise: String) {
        guard verbosity != .minimal else { return }

        let text = isGerman
            ? "Starte \(planName). Erste Übung: \(firstExercise). Los geht's!"
            : "Starting \(planName). First up: \(firstExercise). Let's do this."
        announce(text, rate: 0.50)
    }

    /// Called when moving to next exercise
    func announceExercise(_ name: String) {
        guard verbosity != .minimal else { return }

        let text = isGerman
            ? "Nächste Übung: \(name). Mach dich bereit."
            : "Next up: \(name). Get ready."
        announce(text, rate: 0.52)
    }

    /// Called when a set is completed and rest begins
    func announceSetCompleted() {
        guard verbosity != .minimal else { return }

        let phrases = isGerman ? setCompletedPhrasesDE : setCompletedPhrasesEN
        let phrase = selectPhrase(from: phrases, category: .setComplete)
        announce(phrase, rate: 0.53)
    }

    /// Called when rest ends and next set begins
    func announceRestEnd() {
        let phrases = isGerman ? restEndPhrasesDE : restEndPhrasesEN
        let phrase = selectPhrase(from: phrases, category: .restEnd)
        announce(phrase, rate: 0.55)
    }

    /// Alias for announceRestEnd (for backwards compatibility)
    func announceSetStart() {
        announceRestEnd()
    }

    /// Called for countdown (3, 2, 1)
    func announceCountdown(_ number: Int) {
        // Respect countdown setting
        guard AppSettings.shared.isVoiceCountdownEnabled else { return }

        let text: String
        if isGerman {
            switch number {
            case 3: text = "Drei"
            case 2: text = "Zwei"
            case 1: text = "Eins"
            default: text = "\(number)"
            }
        } else {
            switch number {
            case 3: text = "Three"
            case 2: text = "Two"
            case 1: text = "One"
            default: text = "\(number)"
            }
        }
        announce(text, rate: 0.58)
    }

    /// Called when entire workout is complete
    func announceWorkoutComplete() {
        let phrases = isGerman ? workoutCompletePhrasesDE : workoutCompletePhrasesEN
        let phrase = selectPhrase(from: phrases, category: .workoutComplete)
        announce(phrase, rate: 0.48)
    }

    /// Called for extra motivation (only in high verbosity)
    func announceMotivationTip() {
        guard verbosity == .high else { return }

        let tips = isGerman ? motivationTipsDE : motivationTipsEN
        let tip = selectPhrase(from: tips, category: .motivationTip)
        announce(tip, rate: 0.50)
    }

    /// Announce pause state
    func announcePaused() {
        guard verbosity != .minimal else { return }

        let text = isGerman ? "Pausiert" : "Paused"
        announce(text, rate: 0.52)
    }

    /// Announce resume state
    func announceResumed() {
        guard verbosity != .minimal else { return }

        let text = isGerman ? "Weiter geht's" : "Let's continue"
        announce(text, rate: 0.52)
    }

    // MARK: - Stop

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
