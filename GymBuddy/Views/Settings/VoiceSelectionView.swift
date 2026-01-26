import SwiftUI
import AVFoundation

struct VoiceSelectionView: View {
    @State private var settings = AppSettings.shared
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var playingVoiceId: String?

    /// Sorted voices: Premium first, then Enhanced, then Standard
    private var sortedVoices: [AVSpeechSynthesisVoice] {
        settings.availableVoices.sorted { v1, v2 in
            let q1 = qualityRank(v1)
            let q2 = qualityRank(v2)
            if q1 != q2 {
                return q1 > q2  // Higher quality first
            }
            return v1.name < v2.name  // Alphabetical within same quality
        }
    }

    /// Returns quality rank: Premium=3, Enhanced=2, Default=1
    private func qualityRank(_ voice: AVSpeechSynthesisVoice) -> Int {
        // Check identifier for premium voices
        if voice.identifier.contains("premium") {
            return 3
        }
        if voice.quality == .enhanced || voice.identifier.contains("enhanced") {
            return 2
        }
        return 1
    }

    var body: some View {
        List {
            // Auto-Select option (uses AudioService priority list)
            autoSelectRow

            // Available voices for current language
            Section {
                ForEach(sortedVoices, id: \.identifier) { voice in
                    voiceRow(for: voice)
                }
            } header: {
                HStack {
                    Text("\(settings.appLanguage.displayName.uppercased()) VOICES")
                    Spacer()
                    Text("\(sortedVoices.count) available")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
                }
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

    // MARK: - Auto-Select Row

    private var autoSelectRow: some View {
        Section {
            Button {
                settings.preferredVoiceIdentifier = nil
                AudioService.shared.invalidateVoiceCache()
                HapticService.shared.light()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Auto-Select Best")
                                .font(Theme.Fonts.body)
                                .foregroundStyle(Theme.Colors.textPrimary)

                            Text("RECOMMENDED")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.Colors.accent.opacity(0.2))
                                .foregroundStyle(Theme.Colors.accent)
                                .cornerRadius(4)
                        }

                        Text("Automatically uses the best available voice")
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
        } footer: {
            Text("Premium voices sound most natural. Download them in iOS Settings → Accessibility → Spoken Content → Voices.")
                .font(.system(size: 11))
                .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Voice Row

    private func voiceRow(for voice: AVSpeechSynthesisVoice) -> some View {
        HStack {
            Button {
                settings.preferredVoiceIdentifier = voice.identifier
                AudioService.shared.invalidateVoiceCache()
                HapticService.shared.light()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(voice.name)
                                .font(Theme.Fonts.body)
                                .foregroundStyle(Theme.Colors.textPrimary)

                            // Quality badge
                            qualityBadge(for: voice)
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

    // MARK: - Quality Badge

    @ViewBuilder
    private func qualityBadge(for voice: AVSpeechSynthesisVoice) -> some View {
        let rank = qualityRank(voice)

        if rank == 3 {
            // Premium
            Text("PREMIUM")
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.purple.opacity(0.2))
                .foregroundStyle(.purple)
                .cornerRadius(4)
        } else if rank == 2 {
            // Enhanced
            Text("ENHANCED")
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Theme.Colors.accent.opacity(0.2))
                .foregroundStyle(Theme.Colors.accent)
                .cornerRadius(4)
        }
        // No badge for standard voices
    }

    // MARK: - Helpers

    private func voiceDescription(for voice: AVSpeechSynthesisVoice) -> String {
        let rank = qualityRank(voice)
        let quality: String
        switch rank {
        case 3: quality = "Premium Quality"
        case 2: quality = "High Quality"
        default: quality = "Standard"
        }

        let gender: String
        switch voice.gender {
        case .male: gender = "Male"
        case .female: gender = "Female"
        default: gender = "Neutral"
        }

        return "\(gender) · \(quality)"
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
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.08
        utterance.volume = 1.0

        playingVoiceId = voice.identifier
        synthesizer.speak(utterance)

        // Reset playing state after speech completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if playingVoiceId == voice.identifier {
                playingVoiceId = nil
            }
        }
    }
}

#Preview {
    NavigationStack {
        VoiceSelectionView()
    }
}
