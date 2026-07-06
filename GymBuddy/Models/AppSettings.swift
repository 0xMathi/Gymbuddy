import Foundation

// MARK: - Enums

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return L.appearanceSystem
        case .light: return L.appearanceLight
        case .dark: return L.appearanceDark
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

// MARK: - AppLanguage

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case german = "de"
    case english = "en"

    var id: String { rawValue }

    /// Language names are proper nouns — shown in their own language on purpose
    var displayName: String {
        switch self {
        case .system: return L.languageSystem
        case .german: return "Deutsch"
        case .english: return "English"
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
        static let defaultRestSeconds = "defaultRestSeconds"
        static let weightUnit = "weightUnit"
        static let appLanguage = "appLanguage"
    }

    // MARK: - Properties

    var appearanceMode: AppearanceMode {
        didSet { save(appearanceMode.rawValue, forKey: Keys.appearanceMode) }
    }

    var defaultRestSeconds: Int {
        didSet { save(defaultRestSeconds, forKey: Keys.defaultRestSeconds) }
    }

    var weightUnit: WeightUnit {
        didSet { save(weightUnit.rawValue, forKey: Keys.weightUnit) }
    }

    var appLanguage: AppLanguage {
        didSet { save(appLanguage.rawValue, forKey: Keys.appLanguage) }
    }

    /// Single source of truth for the UI language, used by `L` and
    /// ExerciseLocalization. Reading it inside a view body makes the view
    /// re-render when the in-app language changes (@Observable tracking).
    var resolvedLanguageIsGerman: Bool {
        switch appLanguage {
        case .system: return (Bundle.main.preferredLocalizations.first ?? "en").hasPrefix("de")
        case .german: return true
        case .english: return false
        }
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

        // Load default rest seconds (default: 90)
        let storedRest = defaults.integer(forKey: Keys.defaultRestSeconds)
        self.defaultRestSeconds = storedRest > 0 ? storedRest : 90

        // Load weight unit (default: region-based — set explicitly during onboarding)
        if let rawUnit = defaults.string(forKey: Keys.weightUnit),
           let unit = WeightUnit(rawValue: rawUnit) {
            self.weightUnit = unit
        } else {
            self.weightUnit = WeightUnit.regionDefault
        }

        // Load app language (default: follow the system)
        if let rawLang = defaults.string(forKey: Keys.appLanguage),
           let lang = AppLanguage(rawValue: rawLang) {
            self.appLanguage = lang
        } else {
            self.appLanguage = .system
        }
    }

    // MARK: - Persistence Helpers

    private func save(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
