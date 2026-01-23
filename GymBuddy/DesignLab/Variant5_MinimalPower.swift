import SwiftUI

/// VARIANT 5: "MINIMAL POWER" - Maximum Impact, Minimum Elements
/// Extreme whitespace, giant typography, one bold CTA
/// Subtle animated background texture
struct Variant5_MinimalPower: View {
    @State private var isAnimating = false
    @State private var breatheAnimation = false

    var body: some View {
        ZStack {
            // Animated gradient background
            animatedBackground

            VStack(spacing: 0) {
                Spacer()

                // Central typography
                VStack(spacing: Theme.Spacing.xl) {
                    // Small label
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 24, height: 2)

                        Text("PUSH DAY")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(4)
                            .foregroundStyle(Theme.Colors.textSecondary)

                        Rectangle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 24, height: 2)
                    }
                    .opacity(isAnimating ? 1 : 0)

                    // Giant workout name
                    VStack(spacing: -20) {
                        Text("CHEST")
                            .font(.system(size: 64, weight: .black))
                            .tracking(-2)
                            .foregroundStyle(.white)

                        Text("&")
                            .font(.system(size: 40, weight: .light))
                            .foregroundStyle(Theme.Colors.accent)

                        Text("TRIS")
                            .font(.system(size: 64, weight: .black))
                            .tracking(-2)
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(breatheAnimation ? 1.02 : 1.0)
                    .offset(y: isAnimating ? 0 : 40)
                    .opacity(isAnimating ? 1 : 0)

                    // Workout specs
                    HStack(spacing: Theme.Spacing.xxl) {
                        MinimalStat(value: "6", label: "EXERCISES")
                        MinimalStat(value: "~50", label: "MINUTES")
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
                }

                Spacer()

                // Image hint - very subtle
                ZStack {
                    Circle()
                        .fill(Theme.Colors.surface)
                        .frame(width: 100, height: 100)

                    Circle()
                        .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 1)
                        .frame(width: 100, height: 100)
                        .scaleEffect(breatheAnimation ? 1.3 : 1.0)
                        .opacity(breatheAnimation ? 0 : 0.5)

                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.Colors.accent.opacity(0.6))
                }
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)

                Spacer()

                // Minimal CTA
                VStack(spacing: Theme.Spacing.large) {
                    Button(action: {}) {
                        Text("GO")
                            .font(.system(size: 24, weight: .black))
                            .tracking(8)
                            .foregroundStyle(.black)
                            .frame(width: 120, height: 120)
                            .background(Theme.Colors.accent)
                            .clipShape(Circle())
                    }
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: isAnimating)

                    Button(action: {}) {
                        Text("or choose another plan")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.7), value: isAnimating)
                }
                .padding(.bottom, Theme.Spacing.xxxl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }

            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                breatheAnimation = true
            }
        }
    }

    private var animatedBackground: some View {
        ZStack {
            Theme.Colors.bg

            // Subtle radial gradient
            RadialGradient(
                colors: [
                    Theme.Colors.accent.opacity(0.05),
                    Theme.Colors.bg
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )

            // Very subtle grid
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 60
                    for x in stride(from: 0, to: geo.size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    for y in stride(from: 0, to: geo.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.02), lineWidth: 0.5)
            }
        }
        .ignoresSafeArea()
    }
}

struct MinimalStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}

#Preview {
    Variant5_MinimalPower()
}
