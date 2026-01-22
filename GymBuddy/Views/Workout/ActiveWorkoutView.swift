import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var manager: WorkoutSessionManager

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            if let session = manager.session, let exercise = session.currentExercise {
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
                            Text("/ \(exercise.sets)")
                                .font(Theme.Fonts.h1)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }

                    Spacer()

                    // Progress Dots
                    progressDots(current: session.currentSetNumber, total: exercise.sets)
                        .padding(.bottom, Theme.Spacing.xl)

                    // Controls
                    VStack(spacing: Theme.Spacing.medium) {
                        PrimaryButton(title: "COMPLETE SET", icon: "checkmark") {
                            manager.completeSet()
                        }

                        Button(action: { manager.cancelWorkout() }) {
                            Text("END WORKOUT")
                                .font(Theme.Fonts.label)
                                .tracking(1.5)
                                .foregroundStyle(Theme.Colors.destructive)
                        }
                        .padding(.top, Theme.Spacing.small)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.xxl)
                }

                // Rest Overlay
                if session.state == .resting {
                    RestTimerView(timeRemaining: session.restTimeRemaining) {
                        manager.skipRest()
                    }
                    .transition(.opacity)
                }
            } else {
                Text("Loading...")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: manager.session?.state)
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
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}

#Preview {
    let manager = WorkoutSessionManager()
    ActiveWorkoutView(manager: manager)
}
