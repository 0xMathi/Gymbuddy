import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var manager: WorkoutSessionManager

    @State private var showCancelConfirmation = false
    @State private var selectedExerciseIndex: Int? = nil

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            if let session = manager.session, session.state == .completed {
                WorkoutSummaryView(session: session) {
                    manager.dismissSummary()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))

            } else if let session = manager.session {
                mainContent(session: session)

            } else {
                loadingView
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.session?.state)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: manager.isPaused)
    }

    // MARK: - Main Content

    @ViewBuilder
    private func mainContent(session: WorkoutSession) -> some View {
        let exercises = session.sortedExercises

        VStack(spacing: 0) {
            topBar(session: session)
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.medium)
                .padding(.bottom, Theme.Spacing.small)

            exerciseProgressBar(
                current: session.currentExerciseIndex + 1,
                total: max(exercises.count, 1)
            )
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.medium)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: Theme.Spacing.medium) {
                    if session.state == .resting {
                        restSection(session: session, exercises: exercises)
                            .padding(.horizontal, Theme.Spacing.xl)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else {
                        activeSection(session: session, exercises: exercises)
                            .padding(.horizontal, Theme.Spacing.xl)
                            .transition(.opacity)
                    }

                    if exercises.count > 1 {
                        let hasOthers = exercises.indices.contains(where: { $0 != session.currentExerciseIndex })
                        if hasOthers {
                            sectionDivider(title: session.state == .resting ? "COMING UP" : "NEXT UP")
                                .padding(.horizontal, Theme.Spacing.xl)
                                .padding(.top, Theme.Spacing.small)

                            ForEach(Array(exercises.enumerated()), id: \.element.id) { idx, exercise in
                                if idx != session.currentExerciseIndex {
                                    collapsedExerciseRow(
                                        exercise: exercise,
                                        index: idx,
                                        isCompleted: idx < session.currentExerciseIndex
                                    )
                                    .padding(.horizontal, Theme.Spacing.xl)
                                }
                            }
                        }
                    }

                    // End Workout button at bottom of scroll
                    Button {
                        showCancelConfirmation = true
                    } label: {
                        HStack(spacing: Theme.Spacing.small) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 15, weight: .medium))
                            Text("END WORKOUT")
                                .font(Theme.Fonts.label)
                                .tracking(1)
                        }
                        .foregroundStyle(Theme.Colors.destructive.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.medium)
                        .background(Theme.Colors.destructive.opacity(0.08))
                        .cornerRadius(Theme.Layout.cornerRadius)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.top, Theme.Spacing.large)
                }
                .padding(.top, Theme.Spacing.small)
                .padding(.bottom, Theme.Spacing.xxxl)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: session.currentExerciseIndex)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: session.state)
        .sheet(item: Binding(
            get: { selectedExerciseIndex.map { ExerciseIndexWrapper(index: $0) } },
            set: { selectedExerciseIndex = $0?.index }
        )) { wrapper in
            let exercises = session.sortedExercises
            if exercises.indices.contains(wrapper.index) {
                ExerciseQuickActionSheet(
                    exercise: exercises[wrapper.index],
                    isCompleted: wrapper.index < session.currentExerciseIndex,
                    onJump: {
                        manager.jumpToExercise(index: wrapper.index)
                        selectedExerciseIndex = nil
                    },
                    onMarkComplete: {
                        manager.markExerciseComplete(index: wrapper.index)
                        selectedExerciseIndex = nil
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }

        if manager.isPaused {
            pauseOverlay
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    // MARK: - Top Bar

    private func topBar(session: WorkoutSession) -> some View {
        HStack {
            Button {
                showCancelConfirmation = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("END")
                        .font(Theme.Fonts.label)
                        .tracking(1)
                }
                .foregroundStyle(Theme.Colors.destructive)
                .padding(.horizontal, Theme.Spacing.medium)
                .padding(.vertical, Theme.Spacing.small)
                .background(Theme.Colors.destructive.opacity(0.12))
                .cornerRadius(Theme.Layout.cornerRadiusSmall)
            }
            .buttonStyle(.plain)
            .confirmationDialog("End Workout?", isPresented: $showCancelConfirmation, titleVisibility: .visible) {
                Button("End Workout", role: .destructive) {
                    manager.cancelWorkout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your progress will be lost.")
            }

            Spacer()

            Text(session.plan.name.uppercased())
                .font(Theme.Fonts.label)
                .tracking(2)
                .foregroundStyle(Theme.Colors.textSecondary)
                .lineLimit(1)

            Spacer()

            Button {
                manager.togglePause()
            } label: {
                Image(systemName: manager.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.Layout.cornerRadiusSmall)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Exercise Progress Bar

    private func exerciseProgressBar(current: Int, total: Int) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Colors.surfaceElevated)
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Colors.accent)
                        .frame(width: geo.size.width * (Double(current) / Double(total)), height: 3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: current)
                }
            }
            .frame(height: 3)

            HStack {
                Spacer()
                Text("\(current) / \(total) EX")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }

    // MARK: - STATE A: Active Section

    @ViewBuilder
    private func activeSection(session: WorkoutSession, exercises: [Exercise]) -> some View {
        if let exercise = session.currentExercise {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    if !exercise.muscleGroup.isEmpty {
                        Text(exercise.muscleGroup.uppercased())
                            .font(Theme.Fonts.caption)
                            .tracking(2)
                            .foregroundStyle(Theme.Colors.accent)
                    }

                    Text(exercise.name.uppercased())
                        .font(Theme.Fonts.h1)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .tracking(0.5)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if exercise.weight > 0 {
                        Text(exercise.weightFormatted)
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }

                expandedExerciseCard(exercise: exercise, currentSet: session.currentSetNumber)

                PrimaryButton(title: "COMPLETE SET", icon: "checkmark") {
                    manager.completeSet()
                }
                .disabled(manager.isPaused)
                .opacity(manager.isPaused ? 0.4 : 1.0)
            }
        }
    }

    // MARK: - Expanded Exercise Card

    private func expandedExerciseCard(exercise: Exercise, currentSet: Int) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack {
                Text("SET  \(currentSet) / \(exercise.sets)")
                    .font(Theme.Fonts.label)
                    .tracking(2)
                    .foregroundStyle(Theme.Colors.textSecondary)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(1...max(exercise.sets, 1), id: \.self) { i in
                        Circle()
                            .fill(
                                i < currentSet ? Theme.Colors.success :
                                i == currentSet ? Theme.Colors.accent :
                                Theme.Colors.surfaceElevated
                            )
                            .frame(
                                width: i == currentSet ? 13 : 9,
                                height: i == currentSet ? 13 : 9
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentSet)
                    }
                }
            }

            HStack(spacing: Theme.Spacing.small) {
                if exercise.weight > 0 {
                    metaPill(icon: "scalemass", value: exercise.weightFormatted)
                }
                metaPill(icon: "arrow.up.arrow.down", value: "\(exercise.reps) REPS")
                metaPill(icon: "timer", value: "\(exercise.restSeconds)s REST")
            }
        }
        .padding(Theme.Spacing.medium)
        .background(Theme.Colors.surfaceElevated)
        .cornerRadius(Theme.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                .stroke(Theme.Colors.accent.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - STATE B: Rest Section

    @ViewBuilder
    private func restSection(session: WorkoutSession, exercises: [Exercise]) -> some View {
        let exercise = exercises.indices.contains(session.currentExerciseIndex)
            ? exercises[session.currentExerciseIndex] : nil

        let nextLabel: String = {
            guard let ex = exercise else { return "FINISH" }
            if session.currentSetNumber <= ex.sets {
                return "\(ex.name.uppercased()) — SET \(session.currentSetNumber)"
            } else if session.currentExerciseIndex + 1 < exercises.count {
                return exercises[session.currentExerciseIndex + 1].name.uppercased()
            } else {
                return "LAST SET"
            }
        }()

        VStack(spacing: Theme.Spacing.large) {
            VStack(spacing: Theme.Spacing.xs) {
                Text("RESTING")
                    .font(Theme.Fonts.label)
                    .tracking(4)
                    .foregroundStyle(Theme.Colors.textSecondary)

                Text(nextLabel)
                    .font(Theme.Fonts.h2)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RestTimerBar(
                timeRemaining: session.restTimeRemaining,
                totalDuration: max(session.originalRestDuration, 1),
                onAdjust: { seconds in manager.adjustRest(by: seconds) }
            )
            .padding(Theme.Spacing.large)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)

            SecondaryButton(title: "SKIP REST", icon: "forward.fill") {
                manager.skipRest()
            }
        }
    }

    // MARK: - Collapsed Exercise Row (tappable)

    private func collapsedExerciseRow(exercise: Exercise, index: Int, isCompleted: Bool) -> some View {
        Button {
            selectedExerciseIndex = index
        } label: {
            HStack(spacing: Theme.Spacing.medium) {
                Circle()
                    .fill(isCompleted ? Theme.Colors.success : Theme.Colors.surfaceElevated)
                    .frame(width: 8, height: 8)

                Text(exercise.name.uppercased())
                    .font(Theme.Fonts.label)
                    .tracking(0.5)
                    .foregroundStyle(isCompleted ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                Text("\(exercise.sets)×\(exercise.reps)")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)

                if exercise.weight > 0 {
                    Text("·")
                        .foregroundStyle(Theme.Colors.textSecondary)
                    Text(exercise.weightFormatted)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.surfaceElevated)
            }
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small + 2)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadiusSmall)
            .opacity(isCompleted ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section Divider

    private func sectionDivider(title: String) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            Rectangle()
                .fill(Theme.Colors.surfaceElevated)
                .frame(height: 1)

            Text(title)
                .font(Theme.Fonts.caption)
                .tracking(3)
                .foregroundStyle(Theme.Colors.textSecondary)
                .fixedSize()

            Rectangle()
                .fill(Theme.Colors.surfaceElevated)
                .frame(height: 1)
        }
    }

    // MARK: - Meta Pill

    private func metaPill(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(value)
                .font(Theme.Fonts.caption)
        }
        .foregroundStyle(Theme.Colors.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.Colors.surface)
        .cornerRadius(8)
    }

    // MARK: - Pause Overlay (tappable to resume)

    private var pauseOverlay: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.Colors.accent)

            Text("WORKOUT PAUSED")
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
                .tracking(2)

            Text("TAP ANYWHERE TO RESUME")
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.bg.opacity(0.95))
        .contentShape(Rectangle())
        .onTapGesture {
            manager.togglePause()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
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

// MARK: - Exercise Index Wrapper

private struct ExerciseIndexWrapper: Identifiable {
    let id = UUID()
    let index: Int
}

// MARK: - Exercise Quick Action Sheet

private struct ExerciseQuickActionSheet: View {
    let exercise: Exercise
    let isCompleted: Bool
    let onJump: () -> Void
    let onMarkComplete: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                // Header
                VStack(spacing: Theme.Spacing.xs) {
                    if !exercise.muscleGroup.isEmpty {
                        Text(exercise.muscleGroup.uppercased())
                            .font(Theme.Fonts.caption)
                            .tracking(2)
                            .foregroundStyle(Theme.Colors.accent)
                    }
                    Text(exercise.name.uppercased())
                        .font(Theme.Fonts.h2)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .tracking(0.5)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.top, Theme.Spacing.large)

                // Stats row
                HStack(spacing: Theme.Spacing.xl) {
                    statItem(value: "\(exercise.sets)", label: "SETS")
                    statItem(value: "\(exercise.reps)", label: "REPS")
                    if exercise.weight > 0 {
                        statItem(value: exercise.weightFormatted, label: "WEIGHT")
                    }
                    statItem(value: "\(exercise.restSeconds)s", label: "REST")
                }
                .padding(.horizontal, Theme.Spacing.xl)

                Spacer()

                // Actions
                VStack(spacing: Theme.Spacing.medium) {
                    if isCompleted {
                        HStack(spacing: Theme.Spacing.small) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.Colors.success)
                            Text("ALREADY COMPLETED")
                                .font(Theme.Fonts.label)
                                .tracking(2)
                                .foregroundStyle(Theme.Colors.success)
                        }
                    } else {
                        PrimaryButton(title: "JUMP TO THIS EXERCISE", icon: "arrow.right") {
                            onJump()
                        }

                        SecondaryButton(title: "MARK AS COMPLETE", icon: "checkmark.circle") {
                            onMarkComplete()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
            Text(label)
                .font(Theme.Fonts.caption)
                .tracking(2)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}

#Preview {
    let manager = WorkoutSessionManager()
    ActiveWorkoutView(manager: manager)
}
