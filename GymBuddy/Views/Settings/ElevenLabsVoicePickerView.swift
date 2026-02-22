import SwiftUI
import AVFoundation

// MARK: - ElevenLabs Voice Catalog

enum ElevenLabsVoice: String, CaseIterable, Identifiable {
    // Female Voices
    case rachel = "21m00Tcm4TlvDq8ikWAM"      // Rachel - Calm, clear
    case domi = "AZnzlk1XvdvUeBnXmlld"        // Domi - Strong, confident
    case bella = "EXAVITQu4vr4xnSDxMaL"       // Bella - Soft, warm
    case elli = "MF3mGyEYCl7XYWbV9V6O"        // Elli - Young, energetic
    case charlotte = "XB0fDUnXU5powFXDhCwa"   // Charlotte - Swedish, clear

    // Male Voices
    case adam = "pNInz6obpgDQGcFmaJgB"        // Adam - Deep, authoritative
    case antoni = "ErXwobaYiN019PkySvjV"      // Antoni - Warm, friendly
    case josh = "TxGEqnHWrfWFTfGW9XjX"        // Josh - Young, dynamic
    case arnold = "VR6AewLTigWG4xSOukaG"      // Arnold - Strong, commanding
    case sam = "yoZ06aMxZJJ28mfd3POQ"         // Sam - Raspy, motivating

    var id: String { rawValue }

    var name: String {
        switch self {
        case .rachel: return "Rachel"
        case .domi: return "Domi"
        case .bella: return "Bella"
        case .elli: return "Elli"
        case .charlotte: return "Charlotte"
        case .adam: return "Adam"
        case .antoni: return "Antoni"
        case .josh: return "Josh"
        case .arnold: return "Arnold"
        case .sam: return "Sam"
        }
    }

    var description: String {
        switch self {
        case .rachel: return "Calm & Clear"
        case .domi: return "Strong & Confident"
        case .bella: return "Soft & Warm"
        case .elli: return "Young & Energetic"
        case .charlotte: return "Swedish Accent"
        case .adam: return "Deep & Authoritative"
        case .antoni: return "Warm & Friendly"
        case .josh: return "Young & Dynamic"
        case .arnold: return "Strong & Commanding"
        case .sam: return "Raspy & Motivating"
        }
    }

    var gender: String {
        switch self {
        case .rachel, .domi, .bella, .elli, .charlotte:
            return "Female"
        case .adam, .antoni, .josh, .arnold, .sam:
            return "Male"
        }
    }

    var icon: String {
        gender == "Female" ? "person.fill" : "person.fill"
    }

    /// Recommended for gym coaching
    var isRecommended: Bool {
        switch self {
        case .adam, .josh, .domi, .sam: return true
        default: return false
        }
    }
}

// MARK: - Voice Picker View

struct ElevenLabsVoicePickerView: View {
    @State private var settings = AppSettings.shared
    @State private var isPlaying = false
    @State private var playingVoiceId: String?

    private var sortedVoices: [ElevenLabsVoice] {
        ElevenLabsVoice.allCases.sorted { v1, v2 in
            // Recommended first, then alphabetical
            if v1.isRecommended != v2.isRecommended {
                return v1.isRecommended
            }
            return v1.name < v2.name
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(sortedVoices) { voice in
                    voiceRow(for: voice)
                }
            } header: {
                Text("SELECT VOICE")
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.textSecondary)
            } footer: {
                Text("Voices marked as COACH are recommended for workout motivation.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.bg)
        .navigationTitle("Premium Voice")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Voice Row

    private func voiceRow(for voice: ElevenLabsVoice) -> some View {
        HStack {
            Button {
                selectVoice(voice)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(voice.name)
                                .font(Theme.Fonts.body)
                                .foregroundStyle(Theme.Colors.textPrimary)

                            if voice.isRecommended {
                                Text("COACH")
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Theme.Colors.accent.opacity(0.2))
                                    .foregroundStyle(Theme.Colors.accent)
                                    .cornerRadius(4)
                            }
                        }

                        Text("\(voice.gender) · \(voice.description)")
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }

                    Spacer()

                    if settings.elevenLabsVoiceId == voice.id {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Colors.accent)
                    }
                }
            }

            // Preview Button
            Button {
                previewVoice(voice)
            } label: {
                Image(systemName: playingVoiceId == voice.id ? "stop.fill" : "play.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(Theme.Colors.surfaceElevated)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(isPlaying && playingVoiceId != voice.id)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Actions

    private func selectVoice(_ voice: ElevenLabsVoice) {
        settings.elevenLabsVoiceId = voice.id
        HapticService.shared.light()

        // Clear cache when voice changes (phrases need to be re-generated)
        AudioCacheService.shared.clearCache()
    }

    private func previewVoice(_ voice: ElevenLabsVoice) {
        if playingVoiceId == voice.id {
            // Stop
            AudioService.shared.stop()
            playingVoiceId = nil
            isPlaying = false
            return
        }

        isPlaying = true
        playingVoiceId = voice.id

        let originalVoiceId = settings.elevenLabsVoiceId

        Task {
            // Temporarily switch voice for preview
            settings.elevenLabsVoiceId = voice.id

            let previewText = settings.appLanguage == .german
                ? "Los geht's! Zeit für den nächsten Satz. Du schaffst das!"
                : "Let's go! Time for the next set. You've got this!"

            do {
                let audioData = try await ElevenLabsService.shared.generateSpeech(text: previewText)
                AudioService.shared.stop()

                // Play directly without caching (preview only)
                let player = try AVAudioPlayer(data: audioData)
                player.volume = 1.0
                player.play()

                // Wait for playback
                try await Task.sleep(nanoseconds: UInt64(player.duration * 1_000_000_000) + 500_000_000)

            } catch {
                print("Preview error: \(error)")
            }

            // Restore original voice
            settings.elevenLabsVoiceId = originalVoiceId

            await MainActor.run {
                playingVoiceId = nil
                isPlaying = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        ElevenLabsVoicePickerView()
    }
}
