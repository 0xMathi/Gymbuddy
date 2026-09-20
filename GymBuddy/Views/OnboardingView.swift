import SwiftUI
import UserNotifications

/// Lean first-run onboarding: Statement → Unit → three explainer cards → Ready+Notifications.
/// Shown only on a fresh install (see ContentView). Honors the brand: short, no noise.
/// The explainer cards cover the three gestures the workout screen never spells out;
/// they are skippable from every card.
struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var settings = AppSettings.shared
    @State private var page = 0

    /// Statement + unit + the explainer cards + ready.
    private var pageCount: Int { 2 + howCards.count + 1 }
    private var readyPageIndex: Int { pageCount - 1 }

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            TabView(selection: $page) {
                statementPage.tag(0)
                unitPage.tag(1)
                howPage(howCards[0], index: 2).tag(2)
                howPage(howCards[1], index: 3).tag(3)
                howPage(howCards[2], index: 4).tag(4)
                readyPage.tag(readyPageIndex)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Progress dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<pageCount, id: \.self) { i in
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

                Text("Your plan.\nEvery set. Tracked.")
                    .font(.system(size: 38, weight: .black, design: .default))
                    .tracking(-1)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L.onbSub)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.small)

            Spacer()

            primaryButton(L.onbGetStarted) { advance(to: 1) }
                .padding(.bottom, 76)
        }
    }

    // MARK: - Screen 2: Unit

    private var unitPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text(L.onbUnitTitle)
                .font(.system(size: 40, weight: .black)).tracking(-1)
                .foregroundStyle(.white)

            Text(L.onbUnitQuestion)
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .padding(.top, Theme.Spacing.small)

            // Big segmented choice
            HStack(spacing: Theme.Spacing.medium) {
                unitCard(.kg, title: L.unitKilograms, subtitle: "kg")
                unitCard(.lb, title: L.unitPounds, subtitle: "lb")
            }
            .padding(.top, Theme.Spacing.xl)

            Text(L.onbUnitChangeable)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
                .padding(.top, Theme.Spacing.medium)

            Spacer()

            primaryButton(L.onbContinue) { advance(to: 2) }
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

    // MARK: - Explainer cards

    /// One explainer card: the copy plus which mini-mockup to draw for it.
    private struct HowCard {
        enum Visual { case swipe, lastTime, editSet }
        let visual: Visual
        let title: String
        let body: String
    }

    /// The three gestures the workout screen never spells out.
    private var howCards: [HowCard] {
        [
            HowCard(visual: .swipe, title: L.onbHowSwipeTitle, body: L.onbHowSwipeBody),
            HowCard(visual: .lastTime, title: L.onbHowLastTimeTitle, body: L.onbHowLastTimeBody),
            HowCard(visual: .editSet, title: L.onbHowSetTitle, body: L.onbHowSetBody),
        ]
    }

    private func howPage(_ card: HowCard, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button(L.skip) { advance(to: readyPageIndex) }
                    .font(Theme.Fonts.caption)
                    .tracking(1.5)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .buttonStyle(.plain)
            }
            .padding(.top, 60)

            Spacer()

            Text(L.onbHowKicker)
                .font(Theme.Fonts.kicker).tracking(3)
                .foregroundStyle(Theme.Colors.accent)

            Text(card.title)
                .font(.system(size: 36, weight: .black)).tracking(-1)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.small)

            Text(card.body)
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.medium)

            howVisual(card.visual)
                .padding(.top, Theme.Spacing.xl)

            Spacer()

            primaryButton(L.onbContinue) { advance(to: index + 1) }
                .padding(.bottom, 76)
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    @ViewBuilder
    private func howVisual(_ visual: HowCard.Visual) -> some View {
        switch visual {
        case .swipe: swipeVisual
        case .lastTime: lastTimeVisual
        case .editSet: editSetVisual
        }
    }

    // MARK: - Card visuals (drawn from Theme, no assets)

    /// The active exercise with the next one waiting a swipe away.
    private var swipeVisual: some View {
        VStack(spacing: Theme.Spacing.medium) {
            ZStack {
                mockExerciseCard(name: L.onbHowSampleNext, meta: L.setsRepsMeta(3, 15), progress: 0.5)
                    .scaleEffect(0.93)
                    .opacity(0.3)
                    .offset(x: 34)

                mockExerciseCard(name: L.onbHowSampleExercise, meta: L.setsRepsMeta(4, 8), progress: 0.33)
                    .offset(x: -10)
            }

            HStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "chevron.compact.left")
                    .font(.system(size: 26, weight: .bold))
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 17, weight: .semibold))
                Image(systemName: "chevron.compact.right")
                    .font(.system(size: 26, weight: .bold))
            }
            .foregroundStyle(Theme.Colors.accent.opacity(0.85))
        }
    }

    /// The active set row with the tappable "last time" ghost label.
    private var lastTimeVisual: some View {
        mockSetRow(showLastTime: true, showTapHint: false)
    }

    /// The same row mid-swipe, delete revealed behind it.
    private var editSetVisual: some View {
        // The row has to size this, not the red shape: a bare RoundedRectangle
        // has no intrinsic height and would stretch over the whole page.
        mockSetRow(showLastTime: false, showTapHint: true)
            .offset(x: -60)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .fill(Theme.Colors.destructive)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.trailing, Theme.Spacing.large)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
    }

    private func mockExerciseCard(name: String, meta: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.Colors.surfaceElevated)
                        .frame(height: 2)
                    Capsule()
                        .fill(Theme.Colors.accent)
                        .frame(width: geo.size.width * progress, height: 2)
                }
            }
            .frame(height: 2)

            Text(name)
                .font(.system(size: 19, weight: .black))
                .foregroundStyle(Theme.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(meta)
                .font(Theme.Fonts.caption).tracking(1)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                .stroke(Theme.Colors.surfaceElevated, lineWidth: 1)
        )
        .cornerRadius(Theme.Layout.cornerRadius)
    }

    /// Mirrors the active set row of the workout screen, in the unit just chosen.
    private func mockSetRow(showLastTime: Bool, showTapHint: Bool) -> some View {
        let unit = settings.weightUnit
        return HStack(spacing: Theme.Spacing.medium) {
            Text(L.setN(2))
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(Theme.Colors.accent)
                .frame(width: 68, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("8 × \(WeightDisplay.string(kg: 35, unit: unit))")
                        .font(.system(size: 21, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    if showTapHint {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Theme.Colors.accent)
                    }
                }

                if showLastTime {
                    HStack(spacing: 6) {
                        Text(L.lastTime(WeightDisplay.string(kg: 32.5, unit: unit, uppercase: true), 8))
                            .font(Theme.Fonts.ghostLabel).tracking(0.8)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(Theme.Colors.accent)
                }
            }

            Spacer(minLength: 4)

            Circle()
                .strokeBorder(Theme.Colors.surfaceElevated, lineWidth: 3)
                .frame(width: 30, height: 30)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, Theme.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.surface)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Theme.Colors.accent)
                .frame(width: 3)
        }
        .cornerRadius(Theme.Layout.cornerRadius)
    }

    // MARK: - Screen 3: Ready + Notifications

    private var readyPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Colors.accent)
                .padding(.bottom, Theme.Spacing.large)

            Text(L.onbReadyTitle)
                .font(.system(size: 44, weight: .black)).tracking(-1)
                .foregroundStyle(.white)

            Text(L.onbReadyBody)
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.medium)

            // Notification priming
            HStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.Colors.accent)
                Text(L.onbNotifPrime)
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

            primaryButton(L.onbAllowNotifs) { requestNotificationsThenFinish() }
            Button(L.onbMaybeLater) { finish() }
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
