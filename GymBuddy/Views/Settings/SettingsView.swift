import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                workoutDefaultsSection
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

    // MARK: - Helpers


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
