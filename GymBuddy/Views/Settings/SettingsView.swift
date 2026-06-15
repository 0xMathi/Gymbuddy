import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var showTipJar = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                workoutDefaultsSection
                supportSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.bg)
            .sheet(isPresented: $showTipJar) { TipJarView() }
            .navigationTitle(L.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L.done) {
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
                Label(L.appearance, systemImage: "paintbrush.fill")
            }
            .pickerStyle(.menu)
        } header: {
            Text(L.appearanceUpper)
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Workout Defaults Section

    private var workoutDefaultsSection: some View {
        Section {
            Picker(selection: $settings.weightUnit) {
                Text(L.unitKgLong).tag(WeightUnit.kg)
                Text(L.unitLbLong).tag(WeightUnit.lb)
            } label: {
                Label(L.unit, systemImage: "scalemass.fill")
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
                Label(L.defaultRest, systemImage: "clock.fill")
            }
            .pickerStyle(.menu)
        } header: {
            Text(L.workoutDefaultsUpper)
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .listRowBackground(Theme.Colors.surface)
    }

    // MARK: - Support Section

    private var supportSection: some View {
        Section {
            Button {
                showTipJar = true
            } label: {
                HStack(spacing: Theme.Spacing.medium) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Theme.Colors.accent)
                    Text(L.supportGymBuddy)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
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
