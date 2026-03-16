import SwiftUI

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    let onDismiss: () -> Void

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Title and Date)
                VStack(spacing: 4) {
                    Text(session.plan.name.components(separatedBy: " ").last?.uppercased() ?? "WORKOUT")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)
                    
                    Text("abgeschlossen am \(formattedDate(session.endTime ?? Date()))")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .padding(.top, Theme.Spacing.xl)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6), value: isAnimating)

                Spacer()

                // Center Image/Icon (Placeholder for Muscle Heatmap)
                ZStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(Theme.Colors.surfaceElevated)
                        .scaleEffect(isAnimating ? 1 : 0.8)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: isAnimating)
                    
                    // Simple "Brust" Label below image
                    Text("Brust")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(y: 80)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
                }
                .frame(height: 200)

                Spacer()

                // Stats List (Tabular)
                VStack(spacing: 0) {
                    statRow(icon: "timer", label: "Trainingsdauer", value: session.durationFormatted)
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "scalemass", label: "Bewegtes Gewicht", value: session.totalVolumeFormatted)
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "figure.arms.open", label: "Übungen", value: "\(session.totalExercises)")
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "checkmark", label: "Sätze", value: "\(session.totalSetsCompleted)")
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "arrow.triangle.2.circlepath", label: "Wiederholungen", value: "\(session.totalExercises * 10 /* rough estimate for now, we dont track per rep */)")
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)

                Spacer()

                // Done Button (Training neu starten / Beenden)
                Button(action: {
                    HapticService.shared.medium()
                    onDismiss()
                }) {
                    Text("Training abschließen")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.bg) // Dark text roughly matches the styling
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.accent)
                        .cornerRadius(8)
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

    // MARK: - Stat Row

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Theme.Colors.textSecondary)
                .frame(width: 24, alignment: .leading)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(Theme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
    
    // Formatter
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
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
