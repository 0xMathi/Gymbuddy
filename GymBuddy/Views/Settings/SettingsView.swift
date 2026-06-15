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
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
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
                Label("Darstellung", systemImage: "paintbrush.fill")
            }
            .pickerStyle(.menu)
        } header: {
            Text("DARSTELLUNG")
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Workout Defaults Section

    private var workoutDefaultsSection: some View {
        Section {
            Picker(selection: $settings.weightUnit) {
                Text("Kilogramm (kg)").tag(WeightUnit.kg)
                Text("Pfund (lb)").tag(WeightUnit.lb)
            } label: {
                Label("Einheit", systemImage: "scalemass.fill")
            }
            .pickerStyle(.menu)

            Picker(selection: $settings.defaultRestSeconds) {
                Text("30 s").tag(30)
                Text("45 s").tag(45)
                Text("60 s").tag(60)
                Text("90 s").tag(90)
                Text("120 s").tag(120)
                Text("180 s").tag(180)
            } label: {
                Label("Standard-Pause", systemImage: "clock.fill")
            }
            .pickerStyle(.menu)
        } header: {
            Text("WORKOUT-STANDARDS")
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
