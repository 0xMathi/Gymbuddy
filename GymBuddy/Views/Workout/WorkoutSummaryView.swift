import SwiftUI

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    let onDismiss: () -> Void

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Victory Header
                VStack(spacing: Theme.Spacing.medium) {
                    Text("WORKOUT")
                        .font(.system(size: 48, weight: .black))
                        .tracking(-2)
                        .foregroundStyle(.white.opacity(0.3))
                        .offset(y: isAnimating ? 0 : -20)
                        .opacity(isAnimating ? 1 : 0)

                    Text("COMPLETE")
                        .font(.system(size: 64, weight: .black))
                        .tracking(-3)
                        .foregroundStyle(.white)
                        .offset(y: isAnimating ? 0 : -10)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)

                    Text("CONGRATS, YOU CRUSHED IT!")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(Theme.Colors.accent)
                        .offset(y: isAnimating ? 0 : 10)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                }

                Spacer()

                // Big Time Display
                VStack(spacing: Theme.Spacing.small) {
                    Text("TOTAL TIME")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(4)
                        .foregroundStyle(Theme.Colors.textSecondary)

                    Text(session.durationFormatted)
                        .font(.system(size: 96, weight: .black, design: .monospaced))
                        .tracking(-4)
                        .foregroundStyle(Theme.Colors.accent)
                        .scaleEffect(isAnimating ? 1 : 0.8)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: isAnimating)
                }

                Spacer()

                // Stats Row
                HStack(spacing: Theme.Spacing.xxl) {
                    statItem(value: "\(session.totalExercises)", label: "EXERCISES")
                    statItem(value: "\(session.totalSetsCompleted)", label: "SETS")
                    statItem(value: session.plan.name.components(separatedBy: " ").last ?? "DONE", label: "WORKOUT")
                }
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)

                Spacer()

                // Done Button
                Button(action: {
                    HapticService.shared.medium()
                    onDismiss()
                }) {
                    Text("DONE")
                        .font(.system(size: 18, weight: .black))
                        .tracking(4)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Theme.Colors.accent)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: isAnimating)
            }

            // Confetti particles (simple version)
            if isAnimating {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Stat Item

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}

// MARK: - Simple Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
                animateParticles(in: geo.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [
            Theme.Colors.accent,
            .white,
            Theme.Colors.accent.opacity(0.7),
            .white.opacity(0.7)
        ]

        particles = (0..<30).map { _ in
            ConfettiParticle(
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -20),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...10),
                opacity: 1.0
            )
        }
    }

    private func animateParticles(in size: CGSize) {
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2...4)

            withAnimation(.easeOut(duration: duration).delay(delay)) {
                particles[i].position = CGPoint(
                    x: particles[i].position.x + CGFloat.random(in: -100...100),
                    y: size.height + 50
                )
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
}

#Preview {
    let plan = WorkoutPlan(name: "Tag 1 – PUSH")
    var session = WorkoutSession(plan: plan)
    session.endTime = Date().addingTimeInterval(2712) // 45:12
    session.state = .completed

    return WorkoutSummaryView(session: session) {
        print("Dismissed")
    }
}
