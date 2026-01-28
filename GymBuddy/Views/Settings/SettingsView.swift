import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showApiKey = false
    @State private var apiKeyInput = ""
    @State private var isTestingVoice = false
    @State private var testResult: String?

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                voiceCoachSection
                elevenLabsSection
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
        .onAppear {
            apiKeyInput = settings.elevenLabsApiKey ?? ""
        }
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

    // MARK: - ElevenLabs Section

    private var elevenLabsSection: some View {
        Section {
            // Voice Selection
            NavigationLink {
                ElevenLabsVoicePickerView()
            } label: {
                HStack {
                    Label("Voice", systemImage: "waveform.circle.fill")
                    Spacer()
                    Text(selectedElevenLabsVoiceName)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }

            // Test Voice Button
            Button {
                testElevenLabsVoice()
            } label: {
                HStack {
                    Label("Test Voice", systemImage: isTestingVoice ? "hourglass" : "play.fill")
                    Spacer()
                    if let result = testResult {
                        Text(result)
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(result == "Success!" ? .green : .red)
                    }
                }
            }
            .disabled(isTestingVoice || settings.elevenLabsApiKey?.isEmpty != false)

            // API Key (collapsed, secure)
            HStack {
                Label("API Key", systemImage: "key.fill")
                Spacer()
                if showApiKey {
                    TextField("Enter API Key", text: $apiKeyInput)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit { saveApiKey() }
                    Button("Save") { saveApiKey() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.accent)
                } else {
                    Button {
                        apiKeyInput = settings.elevenLabsApiKey ?? ""
                        showApiKey = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: settings.elevenLabsApiKey?.isEmpty == false ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(settings.elevenLabsApiKey?.isEmpty == false ? .green : .red)
                            Text(settings.elevenLabsApiKey?.isEmpty == false ? "Configured" : "Not Set")
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }
                }
            }
        } header: {
            Text("PREMIUM VOICE")
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        } footer: {
            Text("Powered by ElevenLabs AI. API key stored securely in Keychain.")
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    private var selectedElevenLabsVoiceName: String {
        ElevenLabsVoice.allCases.first { $0.id == settings.elevenLabsVoiceId }?.name ?? "Rachel"
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

    private func saveApiKey() {
        settings.elevenLabsApiKey = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        showApiKey = false
        testResult = nil
        HapticService.shared.light()
    }

    private func testElevenLabsVoice() {
        isTestingVoice = true
        testResult = nil

        Task {
            do {
                let testText = settings.appLanguage == .german
                    ? "ElevenLabs ist aktiv!"
                    : "ElevenLabs is active!"

                let audioData = try await ElevenLabsService.shared.generateSpeech(text: testText)

                // Cache it
                AudioCacheService.shared.cacheAudio(audioData, for: testText)

                // Play it
                AudioService.shared.announce(testText)

                await MainActor.run {
                    testResult = "Success!"
                    isTestingVoice = false
                }
            } catch {
                await MainActor.run {
                    testResult = "Error"
                    isTestingVoice = false
                    print("ElevenLabs Test Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
