import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var manager: WorkoutSessionManager

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            if let session = manager.session, let exercise = session.currentExercise {
                // Main Content
                VStack(spacing: 0) {
                    // Header - Exercise Name
                    VStack(spacing: Theme.Spacing.medium) {
                        Text(exercise.name.uppercased())
                            .font(Theme.Fonts.h1)
                            .foregroundStyle(Theme.Colors.textPrimary)
                            .tracking(1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Exercise Details
                        HStack(spacing: Theme.Spacing.large) {
                            detailPill(icon: "scalemass", value: exercise.weightFormatted)
                            detailPill(icon: "arrow.up.arrow.down", value: exercise.repsFormatted)
                            detailPill(icon: "timer", value: "\(exercise.restSeconds)s")
                        }
                    }
                    .padding(.top, Theme.Spacing.xxl)

                    Spacer()

                    // Main Set Indicator
                    VStack(spacing: Theme.Spacing.medium) {
                        Text("SET")
                            .font(Theme.Fonts.label)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .tracking(4)

                        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.small) {
                            Text("\(session.currentSetNumber)")
                                .font(.system(size: 120, weight: .black, design: .default))
                                .foregroundStyle(Theme.Colors.accent)
                                .contentTransition(.numericText())
                            Text("/ \(exercise.sets)")
                                .font(Theme.Fonts.h1)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }
                    .scaleEffect(manager.isPaused ? 0.9 : 1.0)
                    .opacity(manager.isPaused ? 0.5 : 1.0)

                    Spacer()

                    // Progress Dots
                    progressDots(current: session.currentSetNumber, total: exercise.sets)
                        .padding(.bottom, Theme.Spacing.xl)

                    // Controls
                    VStack(spacing: Theme.Spacing.medium) {
                        // Complete Set Button
                        PrimaryButton(
                            title: manager.isPaused ? "PAUSED" : "COMPLETE SET",
                            icon: manager.isPaused ? "pause.fill" : "checkmark"
                        ) {
                            if !manager.isPaused {
                                manager.completeSet()
                            }
                        }
                        .opacity(manager.isPaused ? 0.5 : 1.0)

                        // Pause & End Buttons
                        HStack(spacing: Theme.Spacing.large) {
                            Button(action: { manager.togglePause() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: manager.isPaused ? "play.fill" : "pause.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(manager.isPaused ? "RESUME" : "PAUSE")
                                        .font(Theme.Fonts.label)
                                        .tracking(1)
                                }
                                .foregroundStyle(Theme.Colors.textPrimary)
                                .padding(.horizontal, Theme.Spacing.large)
                                .padding(.vertical, Theme.Spacing.medium)
                                .background(Theme.Colors.surface)
                                .cornerRadius(Theme.Layout.cornerRadiusSmall)
                            }

                            Button(action: { manager.cancelWorkout() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("END")
                                        .font(Theme.Fonts.label)
                                        .tracking(1)
                                }
                                .foregroundStyle(Theme.Colors.destructive)
                                .padding(.horizontal, Theme.Spacing.large)
                                .padding(.vertical, Theme.Spacing.medium)
                                .background(Theme.Colors.surface)
                                .cornerRadius(Theme.Layout.cornerRadiusSmall)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.xxl)
                }

                // Pause Overlay
                if manager.isPaused {
                    pauseOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Rest Overlay
                if session.state == .resting && !manager.isPaused {
                    RestTimerView(timeRemaining: session.restTimeRemaining) {
                        manager.skipRest()
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.05)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
                }
            } else {
                // Loading State
                VStack(spacing: Theme.Spacing.medium) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Theme.Colors.accent)
                    Text("LOADING...")
                        .font(Theme.Fonts.label)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .tracking(2)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.session?.state)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: manager.isPaused)
    }

    // MARK: - Pause Overlay

    private var pauseOverlay: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.Colors.accent)

            Text("WORKOUT PAUSED")
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
                .tracking(2)

            Text("Tap Resume to continue")
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.bg.opacity(0.95))
    }

    // MARK: - Detail Pill

    private func detailPill(icon: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(value)
                .font(Theme.Fonts.caption)
        }
        .foregroundStyle(Theme.Colors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.Colors.surface)
        .cornerRadius(8)
    }

    // MARK: - Progress Dots

    private func progressDots(current: Int, total: Int) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            ForEach(1...total, id: \.self) { index in
                Circle()
                    .fill(index < current ? Theme.Colors.success :
                          index == current ? Theme.Colors.accent :
                          Theme.Colors.surfaceElevated)
                    .frame(width: index == current ? 14 : 10, height: index == current ? 14 : 10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: current)
            }
        }
    }
}

#Preview {
    let manager = WorkoutSessionManager()
    ActiveWorkoutView(manager: manager)
}
