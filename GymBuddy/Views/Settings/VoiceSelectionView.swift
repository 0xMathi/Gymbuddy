import SwiftUI
import AVFoundation

struct VoiceSelectionView: View {
    @State private var settings = AppSettings.shared
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var playingVoiceId: String?

    var body: some View {
        List {
            // Default option
            defaultVoiceRow

            // Available voices for current language
            Section {
                ForEach(settings.availableVoices, id: \.identifier) { voice in
                    voiceRow(for: voice)
                }
            } header: {
                Text("\(settings.appLanguage.displayName.uppercased()) VOICES")
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.bg)
        .navigationTitle("Select Voice")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Default Voice Row

    private var defaultVoiceRow: some View {
        Section {
            Button {
                settings.preferredVoiceIdentifier = nil
                HapticService.shared.light()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Default")
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textPrimary)

                        Text("System default for \(settings.appLanguage.displayName)")
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }

                    Spacer()

                    if settings.preferredVoiceIdentifier == nil {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Colors.accent)
                    }
                }
            }
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Voice Row

    private func voiceRow(for voice: AVSpeechSynthesisVoice) -> some View {
        HStack {
            Button {
                settings.preferredVoiceIdentifier = voice.identifier
                HapticService.shared.light()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(voice.name)
                                .font(Theme.Fonts.body)
                                .foregroundStyle(Theme.Colors.textPrimary)

                            if voice.quality == .enhanced {
                                Text("ENHANCED")
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Theme.Colors.accent.opacity(0.2))
                                    .foregroundStyle(Theme.Colors.accent)
                                    .cornerRadius(4)
                            }
                        }

                        Text(voiceDescription(for: voice))
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }

                    Spacer()

                    if settings.preferredVoiceIdentifier == voice.identifier {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Colors.accent)
                    }
                }
            }

            // Test Button
            Button {
                testVoice(voice)
            } label: {
                Image(systemName: playingVoiceId == voice.identifier ? "stop.fill" : "play.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(Theme.Colors.surfaceElevated)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Helpers

    private func voiceDescription(for voice: AVSpeechSynthesisVoice) -> String {
        let quality = voice.quality == .enhanced ? "High Quality" : "Standard"
        let gender = voice.gender == .male ? "Male" : voice.gender == .female ? "Female" : "Neutral"
        return "\(gender) - \(quality)"
    }

    private func testVoice(_ voice: AVSpeechSynthesisVoice) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            playingVoiceId = nil
            return
        }

        let testPhrase: String
        if settings.appLanguage == .german {
            testPhrase = "Los geht's! Nächste Übung: Bankdrücken. Drei Sätze, zehn Wiederholungen."
        } else {
            testPhrase = "Let's go! Next exercise: Bench Press. Three sets, ten reps."
        }

        let utterance = AVSpeechUtterance(string: testPhrase)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        playingVoiceId = voice.identifier
        synthesizer.speak(utterance)

        // Reset playing state after speech completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            playingVoiceId = nil
        }
    }
}

#Preview {
    NavigationStack {
        VoiceSelectionView()
    }
}
