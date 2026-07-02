import SwiftUI
import SwiftData
import StoreKit

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    var previousStats: (duration: TimeInterval, volume: Double)? = nil
    let onDismiss: () -> Void

    @State private var isAnimating = false
    @State private var showTipJar = false
    @Environment(\.requestReview) private var requestReview
    // The workout being summarized is already persisted, so it is included in this count.
    @Query private var completedWorkouts: [CompletedWorkout]

    /// Milestones at which the system rating prompt may appear (iOS caps at 3 per year).
    private var isReviewMilestone: Bool {
        [3, 10, 25].contains(completedWorkouts.count)
    }

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Title and Date)
                VStack(spacing: 4) {
                    Text(session.plan.name.components(separatedBy: " ").last?.uppercased() ?? "WORKOUT")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)
                    
                    Text(L.completedOn(formattedDate(session.endTime ?? Date())))
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .padding(.top, Theme.Spacing.xl)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6), value: isAnimating)

                Spacer()

                // Center Image/Icon (Achievement)
                ZStack {
                    Circle()
                        .fill(Theme.Colors.surfaceElevated.opacity(0.3))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: isAnimating)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.Colors.accent, Theme.Colors.accent.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(isAnimating ? 1 : 0.8)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: isAnimating)
                    
                    Text("BEAST MODE COMPLETED")
                        .font(.system(size: 16, weight: .black))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .offset(y: 100)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
                }
                .frame(height: 240)

                Spacer()

                // Stats List (Tabular)
                VStack(spacing: 0) {
                    statRow(icon: "timer", label: L.duration, value: session.durationFormatted)
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "scalemass", label: L.volume, value: session.totalVolumeFormatted)
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "figure.arms.open", label: L.exercises, value: "\(session.totalExercises)")
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "checkmark", label: L.setsLabel, value: "\(session.totalSetsCompleted)")
                    Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                    statRow(icon: "arrow.triangle.2.circlepath", label: L.repsLabel, value: "\(session.totalRepsCompleted)")

                    if let previous = previousStats {
                        Divider().background(Theme.Colors.surfaceElevated).padding(.vertical, 8)
                        statRow(
                            icon: "clock.arrow.circlepath",
                            label: L.lastSession,
                            value: "\(formatDuration(previous.duration)) · \(formatVolume(previous.volume))"
                        )
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)

                Spacer()

                // Quiet tip-jar entry — the post-workout high is the honest moment to ask
                Button {
                    HapticService.shared.light()
                    showTipJar = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.Colors.accent)
                        Text(L.supportGymBuddy)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, Theme.Spacing.medium)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.55), value: isAnimating)

                // Done Button (Training neu starten / Beenden)
                Button(action: {
                    HapticService.shared.medium()
                    onDismiss()
                }) {
                    Text(L.finishWorkout)
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
        .sheet(isPresented: $showTipJar) { TipJarView() }
        .task {
            guard isReviewMilestone else { return }
            // Let the confetti and stats settle before the system prompt appears
            try? await Task.sleep(for: .seconds(2.5))
            requestReview()
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

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private func formatVolume(_ volume: Double) -> String {
        guard volume > 0 else { return "—" }
        let unit = AppSettings.shared.weightUnit
        let value = unit.value(fromKg: volume).rounded()
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
        return "\(formatted) \(unit.label)"
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
