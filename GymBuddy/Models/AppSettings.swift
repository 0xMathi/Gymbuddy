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

// MARK: - AppSettings

@Observable
final class AppSettings {
    static let shared = AppSettings()

    // MARK: - Keys

    private enum Keys {
        static let appearanceMode = "appearanceMode"
        static let defaultRestSeconds = "defaultRestSeconds"
        static let weightUnit = "weightUnit"
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
    }

    // MARK: - Persistence Helpers

    private func save(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
