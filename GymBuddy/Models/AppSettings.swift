import Foundation
import AVFoundation

// MARK: - Enums

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .german: return "Deutsch"
        }
    }

    var flagEmoji: String {
        switch self {
        case .english: return "EN"
        case .german: return "DE"
        }
    }
}

enum CoachVerbosity: String, CaseIterable, Identifiable {
    case minimal = "minimal"
    case normal = "normal"
    case high = "high"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .minimal: return "Minimal"
        case .normal: return "Normal"
        case .high: return "Detailed"
        }
    }

    var description: String {
        switch self {
        case .minimal: return "Essential cues only"
        case .normal: return "Balanced feedback"
        case .high: return "Full coaching"
        }
    }
}

// MARK: - AppSettings

@Observable
final class AppSettings {
    static let shared = AppSettings()

    // MARK: - Keys

    private enum Keys {
        static let appearanceMode = "appearanceMode"
        static let isVoiceEnabled = "isVoiceEnabled"
        static let appLanguage = "appLanguage"
        static let coachVerbosity = "coachVerbosity"
        static let isVoiceCountdownEnabled = "isVoiceCountdownEnabled"
        static let preferredVoiceIdentifier = "preferredVoiceIdentifier"
        static let defaultRestSeconds = "defaultRestSeconds"
        // ElevenLabs
        static let useElevenLabs = "useElevenLabs"
        static let elevenLabsApiKey = "elevenLabsApiKey"
        static let elevenLabsVoiceId = "elevenLabsVoiceId"
    }

    // MARK: - Properties

    var appearanceMode: AppearanceMode {
        didSet { save(appearanceMode.rawValue, forKey: Keys.appearanceMode) }
    }

    var isVoiceEnabled: Bool {
        didSet { save(isVoiceEnabled, forKey: Keys.isVoiceEnabled) }
    }

    var appLanguage: AppLanguage {
        didSet { save(appLanguage.rawValue, forKey: Keys.appLanguage) }
    }

    var coachVerbosity: CoachVerbosity {
        didSet { save(coachVerbosity.rawValue, forKey: Keys.coachVerbosity) }
    }

    var isVoiceCountdownEnabled: Bool {
        didSet { save(isVoiceCountdownEnabled, forKey: Keys.isVoiceCountdownEnabled) }
    }

    var preferredVoiceIdentifier: String? {
        didSet { save(preferredVoiceIdentifier, forKey: Keys.preferredVoiceIdentifier) }
    }

    var defaultRestSeconds: Int {
        didSet { save(defaultRestSeconds, forKey: Keys.defaultRestSeconds) }
    }

    // MARK: - ElevenLabs Properties

    var useElevenLabs: Bool {
        didSet { save(useElevenLabs, forKey: Keys.useElevenLabs) }
    }

    /// API Key stored securely in Keychain (not UserDefaults)
    var elevenLabsApiKey: String? {
        get { KeychainService.shared.get(.elevenLabsApiKey) }
        set {
            if let value = newValue, !value.isEmpty {
                KeychainService.shared.save(value, for: .elevenLabsApiKey)
            } else {
                KeychainService.shared.delete(.elevenLabsApiKey)
            }
        }
    }

    var elevenLabsVoiceId: String {
        didSet { save(elevenLabsVoiceId, forKey: Keys.elevenLabsVoiceId) }
    }

    // MARK: - Computed Properties

    /// Returns the preferred voice or a default based on language
    var selectedVoice: AVSpeechSynthesisVoice? {
        if let identifier = preferredVoiceIdentifier {
            return AVSpeechSynthesisVoice(identifier: identifier)
        }
        // Fallback to default voice for language
        return AVSpeechSynthesisVoice(language: appLanguage.rawValue)
    }

    /// Available voices for the current language
    var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: appLanguage.rawValue) }
            .sorted { $0.name < $1.name }
    }

    // MARK: - Init

    private init() {
        let defaults = UserDefaults.standard

        // Load appearance mode
        if let rawValue = defaults.string(forKey: Keys.appearanceMode),
           let mode = AppearanceMode(rawValue: rawValue) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }

        // Load voice enabled (default: true)
        if defaults.object(forKey: Keys.isVoiceEnabled) != nil {
            self.isVoiceEnabled = defaults.bool(forKey: Keys.isVoiceEnabled)
        } else {
            self.isVoiceEnabled = true
        }

        // Load app language
        if let rawValue = defaults.string(forKey: Keys.appLanguage),
           let language = AppLanguage(rawValue: rawValue) {
            self.appLanguage = language
        } else {
            // Default based on system language
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            self.appLanguage = systemLang.starts(with: "de") ? .german : .english
        }

        // Load coach verbosity
        if let rawValue = defaults.string(forKey: Keys.coachVerbosity),
           let verbosity = CoachVerbosity(rawValue: rawValue) {
            self.coachVerbosity = verbosity
        } else {
            self.coachVerbosity = .normal
        }

        // Load voice countdown (default: true)
        if defaults.object(forKey: Keys.isVoiceCountdownEnabled) != nil {
            self.isVoiceCountdownEnabled = defaults.bool(forKey: Keys.isVoiceCountdownEnabled)
        } else {
            self.isVoiceCountdownEnabled = true
        }

        // Load preferred voice identifier
        self.preferredVoiceIdentifier = defaults.string(forKey: Keys.preferredVoiceIdentifier)

        // Load default rest seconds (default: 90)
        let storedRest = defaults.integer(forKey: Keys.defaultRestSeconds)
        self.defaultRestSeconds = storedRest > 0 ? storedRest : 90

        // Load ElevenLabs settings (default: enabled)
        if defaults.object(forKey: Keys.useElevenLabs) != nil {
            self.useElevenLabs = defaults.bool(forKey: Keys.useElevenLabs)
        } else {
            self.useElevenLabs = true  // ElevenLabs is now the default
        }

        // Migrate API key from UserDefaults to Keychain (one-time migration)
        if let oldKey = defaults.string(forKey: Keys.elevenLabsApiKey), !oldKey.isEmpty {
            KeychainService.shared.save(oldKey, for: .elevenLabsApiKey)
            defaults.removeObject(forKey: Keys.elevenLabsApiKey)
            print("AppSettings: Migrated API key to Keychain")
        }

        // elevenLabsApiKey is now a computed property that reads from Keychain

        self.elevenLabsVoiceId = defaults.string(forKey: Keys.elevenLabsVoiceId) ?? "21m00Tcm4TlvDq8ikWAM"
    }

    // MARK: - Persistence Helpers

    private func save(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
