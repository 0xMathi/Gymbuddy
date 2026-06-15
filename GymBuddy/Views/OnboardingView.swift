import SwiftUI
import UserNotifications

/// Lean 3-screen first-run onboarding: Statement → Unit → Ready+Notifications.
/// Shown only on a fresh install (see ContentView). Honors the brand: short, no noise.
struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var settings = AppSettings.shared
    @State private var page = 0

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            TabView(selection: $page) {
                statementPage.tag(0)
                unitPage.tag(1)
                readyPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Progress dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Capsule()
                            .fill(i == page ? Theme.Colors.accent : Theme.Colors.surfaceElevated)
                            .frame(width: i == page ? 22 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }
                .padding(.bottom, 50)
            }
            .allowsHitTesting(false)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Screen 1: Statement

    private var statementPage: some View {
        VStack(spacing: 0) {
            // Hero image bleeding from the top (SF Symbol fallback if asset missing)
            ZStack(alignment: .bottom) {
                Group {
                    if let img = UIImage(named: "onboarding_hero") {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Theme.Colors.surface
                            .overlay(
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 80, weight: .thin))
                                    .foregroundStyle(Theme.Colors.accent.opacity(0.5))
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.52)
                .clipped()

                // Fade into the background
                LinearGradient(
                    colors: [.clear, Theme.Colors.bg],
                    startPoint: .center, endPoint: .bottom
                )
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("GYM")
                    .font(.system(size: 12, weight: .black)).tracking(5)
                    .foregroundStyle(Theme.Colors.accent)
                + Text("BUDDY")
                    .font(.system(size: 12, weight: .black)).tracking(5)
                    .foregroundStyle(.white)

                Text("Track every set.\nBeat last time.")
                    .font(.system(size: 38, weight: .black, design: .default))
                    .tracking(-1)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Ein schneller, fokussierter Workout-Tracker. Kein Abo, kein Lärm — nur du und das Eisen.")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.small)

            Spacer()

            primaryButton("Los geht's") { advance(to: 1) }
                .padding(.bottom, 76)
        }
    }

    // MARK: - Screen 2: Unit

    private var unitPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("Deine Einheit.")
                .font(.system(size: 40, weight: .black)).tracking(-1)
                .foregroundStyle(.white)

            Text("In welcher Einheit trainierst du?")
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .padding(.top, Theme.Spacing.small)

            // Big segmented choice
            HStack(spacing: Theme.Spacing.medium) {
                unitCard(.kg, title: "Kilogramm", subtitle: "kg")
                unitCard(.lb, title: "Pfund", subtitle: "lb")
            }
            .padding(.top, Theme.Spacing.xl)

            Text("Jederzeit in den Einstellungen änderbar.")
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
                .padding(.top, Theme.Spacing.medium)

            Spacer()

            primaryButton("Weiter") { advance(to: 2) }
                .padding(.bottom, 76)
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    private func unitCard(_ unit: WeightUnit, title: String, subtitle: String) -> some View {
        let selected = settings.weightUnit == unit
        return Button {
            HapticService.shared.light()
            settings.weightUnit = unit
        } label: {
            VStack(spacing: 6) {
                Text(subtitle.uppercased())
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(selected ? Theme.Colors.accent : Theme.Colors.textPrimary)
                Text(title)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(selected ? Theme.Colors.accent.opacity(0.12) : Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .stroke(selected ? Theme.Colors.accent : Theme.Colors.surfaceElevated, lineWidth: selected ? 2 : 1)
            )
            .cornerRadius(Theme.Layout.cornerRadius)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Screen 3: Ready + Notifications

    private var readyPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Colors.accent)
                .padding(.bottom, Theme.Spacing.large)

            Text("Bereit.")
                .font(.system(size: 44, weight: .black)).tracking(-1)
                .foregroundStyle(.white)

            Text("Push, Pull & Leg Day sind schon eingerichtet — pass sie an oder bau eigene. Tipp einen Plan, und los.")
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.medium)

            // Notification priming
            HStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.Colors.accent)
                Text("Der Pause-Timer piept dich an — auch aus der Tasche.")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Theme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .padding(.top, Theme.Spacing.xl)

            Spacer()

            primaryButton("Mitteilungen erlauben") { requestNotificationsThenFinish() }
            Button("Vielleicht später") { finish() }
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, Theme.Spacing.medium)
                .padding(.bottom, 60)
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    // MARK: - Components & Actions

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.bodyBold)
                .tracking(1)
                .foregroundStyle(Theme.Colors.bg)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Layout.buttonHeight)
                .background(Theme.Colors.accent)
                .cornerRadius(Theme.Layout.buttonHeight / 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Theme.Spacing.xl)
    }

    private func advance(to index: Int) {
        HapticService.shared.light()
        withAnimation(.easeInOut(duration: 0.35)) { page = index }
    }

    private func requestNotificationsThenFinish() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async { finish() }
        }
    }

    private func finish() {
        HapticService.shared.medium()
        onFinish()
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
