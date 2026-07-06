import AppIntents

/// Skip button in the Live Activity / Dynamic Island.
/// A LiveActivityIntent always executes in the app's process, so it can talk to
/// the session manager directly. The widget target compiles this file only to
/// know the intent's shape — hence the WIDGET_EXTENSION guard.
struct SkipRestIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Skip Rest"

    @MainActor
    func perform() async throws -> some IntentResult {
        #if !WIDGET_EXTENSION
        WorkoutSessionManager.shared.skipRest()
        #endif
        return .result()
    }
}
