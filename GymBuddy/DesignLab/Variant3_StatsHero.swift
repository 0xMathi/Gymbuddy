import SwiftUI

/// VARIANT 3: "STATS HERO" - Data + Motivation
/// Shows last workout stats prominently with motivational messaging
/// "READY FOR MORE?" with quick-start for current plan
struct Variant3_StatsHero: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            // Background pattern
            GeometryReader { geo in
                ForEach(0..<30) { i in
                    Rectangle()
                        .fill(Theme.Colors.accent.opacity(0.02))
                        .frame(width: geo.size.width, height: 1)
                        .offset(y: CGFloat(i) * 30)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 120)

                // Last Workout Stats
                VStack(spacing: Theme.Spacing.xl) {
                    Text("LAST SESSION")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(4)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .offset(y: isAnimating ? 0 : -10)
                        .opacity(isAnimating ? 1 : 0)

                    // Big stats row
                    HStack(spacing: Theme.Spacing.xxl) {
                        StatBlock(value: "47", unit: "MIN", label: "Duration")
                        StatBlock(value: "12", unit: "K", label: "Volume (kg)")
                        StatBlock(value: "6", unit: "", label: "Exercises")
                    }
                    .offset(y: isAnimating ? 0 : 20)
                    .opacity(isAnimating ? 1 : 0)
                }
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)

                Spacer()
                    .frame(height: Theme.Spacing.xxxl)

                // Motivational Message
                VStack(spacing: Theme.Spacing.medium) {
                    Text("READY FOR")
                        .font(.system(size: 48, weight: .black))
                        .tracking(-1)
                        .foregroundStyle(.white)

                    HStack(spacing: 0) {
                        Text("MORE")
                            .font(.system(size: 48, weight: .black))
                            .tracking(-1)
                            .foregroundStyle(Theme.Colors.accent)

                        Text("?")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)

                Spacer()

                // Current Plan Quick Start
                VStack(spacing: Theme.Spacing.large) {
                    // Plan info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TODAY'S PLAN")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundStyle(Theme.Colors.textSecondary)

                            Text("PUSH DAY")
                                .font(.system(size: 24, weight: .black))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        // Workout image placeholder
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.surface)
                                .frame(width: 60, height: 60)

                            Circle()
                                .stroke(Theme.Colors.accent, lineWidth: 2)
                                .frame(width: 60, height: 60)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .opacity(pulseAnimation ? 0 : 1)

                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Theme.Colors.accent)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.xl)

                    // Start button
                    Button(action: {}) {
                        HStack(spacing: 16) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .bold))

                            Text("START WORKOUT")
                                .font(.system(size: 16, weight: .black))
                                .tracking(2)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(Theme.Colors.accent)
                        .cornerRadius(0)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                }
                .offset(y: isAnimating ? 0 : 40)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: isAnimating)

                // Browse other plans
                Button(action: {}) {
                    Text("BROWSE ALL PLANS")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .underline()
                }
                .padding(.top, Theme.Spacing.large)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .onAppear {
            isAnimating = true

            // Pulse animation loop
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulseAnimation = true
            }
        }
    }
}

struct StatBlock: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.accent)
                }
            }

            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .tracking(1)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}

#Preview {
    Variant3_StatsHero()
}
