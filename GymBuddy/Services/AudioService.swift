import AVFoundation
import UIKit

class AudioService: NSObject {
    static let shared = AudioService()
    private let synthesizer = AVSpeechSynthesizer()
    private var cachedVoice: AVSpeechSynthesisVoice?
    private var cachedLanguage: AppLanguage?

    // MARK: - ElevenLabs Integration

    private var audioPlayer: AVAudioPlayer?
    private let elevenLabs = ElevenLabsService.shared
    private let audioCache = AudioCacheService.shared

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
        // Power phrases
        "Let's crush this set!",
        "Light weight, baby!",
        "Own this set!",
        "Time to dominate!",
        "Show me what you got!",
        "You've got this!",
        "Let's go beast mode!",
        "This is your moment!",
        "Attack this set!",
        "No excuses. Just results.",
        // Focus phrases
        "Focus. Power. Go!",
        "Strong form, let's go.",
        "Make it look easy.",
        "Full range of motion.",
        "Drive through!",
        "Time to shine.",
        "Lock it in!",
        "Eyes on the prize.",
        "Mental focus, physical power.",
        "Channel your inner beast!",
        // Motivational
        "You're stronger than you think!",
        "Pain is temporary, gains are forever.",
        "Champions are made here.",
        "Push past your limits!",
        "This set defines you!",
        "Leave nothing in the tank!",
        "Make yourself proud!",
        "Embrace the grind!"
    ]

    private let restEndPhrasesEN = [
        // Action calls
        "Time to work!",
        "Let's get it!",
        "Back under the bar!",
        "Next set starts now!",
        "Here we go!",
        "Round two, fight!",
        "Game time!",
        "Rise and grind!",
        "Get after it!",
        "Attack mode activated!",
        // Focus phrases
        "Get ready.",
        "Focus mode: On.",
        "Lock in.",
        "Concentration time.",
        "Clear your mind.",
        "Deep breath and go!",
        "Reset. Refocus. Repeat.",
        // Motivation
        "You rested. Now dominate!",
        "Rest is over. Time to earn it!",
        "Your muscles are ready!",
        "Channel that energy!"
    ]

    private let setCompletedPhrasesEN = [
        // Praise
        "Good set. Rest up.",
        "Nice work! Catch your breath.",
        "Solid work. Take a break.",
        "Strong effort! Relax.",
        "Clean reps! Rest.",
        "That's how it's done!",
        "Excellent execution!",
        "Perfect form!",
        "You killed it!",
        "Crushed it!",
        // Rest reminders
        "Easy money. Rest now.",
        "Done. Recover.",
        "Take your break. You earned it.",
        "Breathe. Recover. Repeat.",
        "Shake it off. Rest up.",
        "Great work. Hydrate!",
        // Motivation
        "One step closer to your goals!",
        "That's progress right there!",
        "Building muscle, building character."
    ]

    private let workoutCompletePhrasesEN = [
        // Celebration
        "Workout destroyed! Excellent job!",
        "You survived! Great session!",
        "Victory! See you next time!",
        "Beast mode complete!",
        "Champion workout!",
        "Absolutely crushed it!",
        "Mission accomplished!",
        "That was epic!",
        // Reflection
        "Session complete. Go eat!",
        "Stronger than yesterday!",
        "Another one in the books.",
        "You showed up. You delivered.",
        "Progress made. Gains incoming!",
        // Motivation for next time
        "Rest well. Come back stronger!",
        "Recovery time. You've earned it!",
        "Today you won. Tomorrow you conquer!",
        "The grind never stops!"
    ]

    private let motivationTipsEN = [
        "Remember to breathe!",
        "Stay hydrated!",
        "Control the negative!",
        "Mind-muscle connection!",
        "Quality over quantity!",
        "Squeeze at the top!",
        "Core tight!",
        "Shoulders back!",
        "Drive through your heels!",
        "Full extension!",
        "Slow and controlled!",
        "Feel the burn!",
        "Trust the process!",
        "Consistency is key!"
    ]

    // MARK: - Motivational Phrases (German)

    private let setStartPhrasesDE = [
        // Power Phrasen
        "Auf geht's!",
        "Leichtes Gewicht!",
        "Der Satz gehört dir!",
        "Zeit zu dominieren!",
        "Zeig was du kannst!",
        "Du schaffst das!",
        "Beast Mode an!",
        "Das ist dein Moment!",
        "Attacke!",
        "Keine Ausreden. Nur Ergebnisse!",
        // Fokus Phrasen
        "Fokus. Kraft. Los!",
        "Saubere Form, los!",
        "Mach es einfach aussehen!",
        "Volle Bewegung!",
        "Durchziehen!",
        "Jetzt wird's ernst!",
        "Bleib fokussiert!",
        "Augen aufs Ziel!",
        "Mental fokus, körperliche Kraft!",
        "Entfessle dein inneres Biest!",
        // Motivation
        "Du bist stärker als du denkst!",
        "Schmerz ist temporär, Gains sind für immer!",
        "Champions werden hier gemacht!",
        "Überschreite deine Grenzen!",
        "Dieser Satz definiert dich!",
        "Gib alles!",
        "Mach dich selbst stolz!",
        "Umarme den Grind!"
    ]

    private let restEndPhrasesDE = [
        // Action Calls
        "Zeit zu arbeiten!",
        "Los geht's!",
        "Zurück ans Eisen!",
        "Nächster Satz jetzt!",
        "Auf geht's!",
        "Runde zwei!",
        "Showtime!",
        "Aufstehen und kämpfen!",
        "Gib Gas!",
        "Angriffsmodus aktiviert!",
        // Fokus Phrasen
        "Mach dich bereit.",
        "Fokus an.",
        "Konzentration.",
        "Tief durchatmen und los!",
        "Reset. Refokus. Wiederholen.",
        // Motivation
        "Du hast geruht. Jetzt dominieren!",
        "Pause vorbei. Zeit es zu verdienen!",
        "Deine Muskeln sind bereit!"
    ]

    private let setCompletedPhrasesDE = [
        // Lob
        "Guter Satz! Pause.",
        "Stark gemacht! Durchatmen.",
        "Solide! Kurze Pause.",
        "Starke Leistung! Ruhe.",
        "Saubere Wiederholungen!",
        "Genau so!",
        "Exzellente Ausführung!",
        "Perfekte Form!",
        "Du hast es gekillt!",
        "Zerstört!",
        // Pausen-Reminder
        "Sauber. Erhol dich.",
        "Fertig. Regenerieren.",
        "Nimm dir die Pause. Du hast sie verdient.",
        "Atmen. Erholen. Wiederholen.",
        "Abschütteln. Ausruhen.",
        "Super Arbeit. Trink was!",
        // Motivation
        "Ein Schritt näher an deinen Zielen!",
        "Das ist Fortschritt!",
        "Muskeln aufbauen, Charakter bilden."
    ]

    private let workoutCompletePhrasesDE = [
        // Feier
        "Workout erledigt! Super gemacht!",
        "Überlebt! Starke Session!",
        "Geschafft! Bis zum nächsten Mal!",
        "Beast Mode beendet!",
        "Champion-Workout!",
        "Absolut zerstört!",
        "Mission erfüllt!",
        "Das war episch!",
        // Reflexion
        "Training komplett. Ab zum Essen!",
        "Stärker als gestern!",
        "Wieder eins geschafft.",
        "Du bist erschienen. Du hast geliefert.",
        "Fortschritt gemacht. Gains kommen!",
        // Motivation für nächstes Mal
        "Ruh dich aus. Komm stärker zurück!",
        "Erholungszeit. Du hast es verdient!",
        "Heute gewonnen. Morgen erobern!",
        "Der Grind stoppt nie!"
    ]

    private let motivationTipsDE = [
        "Denk ans Atmen!",
        "Trink genug Wasser!",
        "Kontrolliere die Bewegung!",
        "Spür den Muskel!",
        "Qualität vor Quantität!",
        "Oben zusammendrücken!",
        "Core anspannen!",
        "Schultern zurück!",
        "Durch die Fersen drücken!",
        "Volle Extension!",
        "Langsam und kontrolliert!",
        "Spür das Brennen!",
        "Vertraue dem Prozess!",
        "Konstanz ist der Schlüssel!"
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

        // Stop any current playback
        stopCurrentPlayback()

        // Check if ElevenLabs is enabled
        if AppSettings.shared.useElevenLabs {
            Task { @MainActor in
                await announceWithElevenLabs(text, fallbackRate: rate)
            }
        } else {
            announceWithNativeVoice(text, rate: rate)
        }
    }

    // MARK: - ElevenLabs Speech

    @MainActor
    private func announceWithElevenLabs(_ text: String, fallbackRate: Float) async {
        // Check cache first
        if let cachedData = audioCache.getCachedAudio(for: text) {
            playAudioData(cachedData)
            return
        }

        // Try to generate with ElevenLabs
        do {
            let audioData = try await elevenLabs.generateSpeech(text: text)

            // Cache the result for future use
            audioCache.cacheAudio(audioData, for: text)

            // Play the audio
            playAudioData(audioData)

        } catch {
            // Log the error
            print("AudioService: ElevenLabs failed, falling back to native voice: \(error.localizedDescription)")

            // Fallback to native Apple voice
            announceWithNativeVoice(text, rate: fallbackRate)
        }
    }

    private func playAudioData(_ data: Data) {
        do {
            // Ensure audio session is configured
            configureAudioSession()

            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

        } catch {
            print("AudioService: Failed to play audio data: \(error.localizedDescription)")
        }
    }

    // MARK: - Native Voice Speech

    private func announceWithNativeVoice(_ text: String, rate: Float) {
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

    private func stopCurrentPlayback() {
        // Stop AVAudioPlayer if playing
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        audioPlayer = nil

        // Stop synthesizer if speaking
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
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
        stopCurrentPlayback()
    }
}
