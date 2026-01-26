import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                voiceCoachSection
                workoutDefaultsSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.Colors.accent)
                    .fontWeight(.semibold)
                }
            }
            .tint(Theme.Colors.accent)
        }
        .preferredColorScheme(colorSchemeFor(settings.appearanceMode))
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        Section {
            Picker(selection: $settings.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Label(mode.displayName, systemImage: mode.iconName)
                        .tag(mode)
                }
            } label: {
                Label("Appearance", systemImage: "paintbrush.fill")
            }
            .pickerStyle(.menu)
        } header: {
            Text("APPEARANCE")
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Voice Coach Section

    private var voiceCoachSection: some View {
        Section {
            // Master Toggle
            Toggle(isOn: $settings.isVoiceEnabled) {
                Label("Voice Coach", systemImage: "speaker.wave.3.fill")
            }
            .tint(Theme.Colors.accent)

            if settings.isVoiceEnabled {
                // Language Picker
                Picker(selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text("\(language.flagEmoji) \(language.displayName)")
                            .tag(language)
                    }
                } label: {
                    Label("Language", systemImage: "globe")
                }
                .pickerStyle(.menu)
                .onChange(of: settings.appLanguage) { _, _ in
                    // Reset voice when language changes
                    settings.preferredVoiceIdentifier = nil
                }

                // Verbosity Picker
                Picker(selection: $settings.coachVerbosity) {
                    ForEach(CoachVerbosity.allCases) { verbosity in
                        VStack(alignment: .leading) {
                            Text(verbosity.displayName)
                        }
                        .tag(verbosity)
                    }
                } label: {
                    Label("Verbosity", systemImage: "text.bubble.fill")
                }
                .pickerStyle(.menu)

                // Countdown Toggle
                Toggle(isOn: $settings.isVoiceCountdownEnabled) {
                    Label("Voice Countdown", systemImage: "timer")
                }
                .tint(Theme.Colors.accent)

                // Voice Selection
                NavigationLink {
                    VoiceSelectionView()
                } label: {
                    HStack {
                        Label("Voice", systemImage: "person.wave.2.fill")
                        Spacer()
                        Text(selectedVoiceName)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
        } header: {
            Text("VOICE COACH")
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        } footer: {
            if settings.isVoiceEnabled {
                Text(settings.coachVerbosity.description)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Workout Defaults Section

    private var workoutDefaultsSection: some View {
        Section {
            Picker(selection: $settings.defaultRestSeconds) {
                Text("30 sec").tag(30)
                Text("45 sec").tag(45)
                Text("60 sec").tag(60)
                Text("90 sec").tag(90)
                Text("120 sec").tag(120)
                Text("180 sec").tag(180)
            } label: {
                Label("Default Rest", systemImage: "clock.fill")
            }
            .pickerStyle(.menu)
        } header: {
            Text("WORKOUT DEFAULTS")
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle.fill")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        } header: {
            Text("ABOUT")
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Helpers

    private var selectedVoiceName: String {
        if let identifier = settings.preferredVoiceIdentifier,
           let voice = settings.availableVoices.first(where: { $0.identifier == identifier }) {
            return voice.name
        }
        return "Default"
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func colorSchemeFor(_ mode: AppearanceMode) -> ColorScheme? {
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

#Preview {
    SettingsView()
}
