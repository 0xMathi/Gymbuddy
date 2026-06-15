import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ActiveWorkoutView: View {
    @Bindable var manager: WorkoutSessionManager

    @State private var showCancelConfirmation = false
    @State private var selectedExerciseIndex: Int? = nil
    @State private var editSetPayload: EditSetPayload? = nil
    @State private var draggedExercise: Exercise?
    @State private var showSettings = false
    /// Browsing preview via horizontal swipe — nil means the active exercise is shown
    @State private var previewIndex: Int? = nil

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            if let session = manager.session, session.state == .completed {
                WorkoutSummaryView(session: session, previousStats: manager.previousSessionStats) {
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
        .confirmationDialog(L.endWorkoutQuestion, isPresented: $showCancelConfirmation, titleVisibility: .visible) {
            Button(L.end, role: .destructive) {
                manager.cancelWorkout()
            }
            Button(L.cancel, role: .cancel) {}
        } message: {
            Text(L.progressLost)
        }
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

            ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: Theme.Spacing.medium) {
                    Color.clear
                        .frame(height: 0)
                        .id("top")

                    if let preview = previewIndex,
                       preview != session.currentExerciseIndex,
                       exercises.indices.contains(preview) {
                        previewSection(session: session, exercises: exercises, index: preview)
                            .id("preview-\(preview)")
                            .padding(.horizontal, Theme.Spacing.xl)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else if session.state == .resting {
                        restSection(session: session, exercises: exercises)
                            .padding(.horizontal, Theme.Spacing.xl)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .onDrop(of: [UTType.text], delegate: ActiveWorkoutDropDelegate(
                                item: exercises[session.currentExerciseIndex],
                                session: session,
                                draggedItem: $draggedExercise
                            ))
                    } else {
                        activeSection(session: session, exercises: exercises)
                            .id("active-\(session.currentExerciseIndex)")
                            .padding(.horizontal, Theme.Spacing.xl)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .onDrop(of: [UTType.text], delegate: ActiveWorkoutDropDelegate(
                                item: exercises[session.currentExerciseIndex],
                                session: session,
                                draggedItem: $draggedExercise
                            ))
                    }

                    if exercises.count > 1 {
                        let hasOthers = exercises.indices.contains(where: { $0 != session.currentExerciseIndex })
                        if hasOthers {
                            let nextEx = session.currentExerciseIndex + 1 < exercises.count ? exercises[session.currentExerciseIndex + 1] : nil
                            let isSupersetNext = session.state != .resting && nextEx?.supersetId != nil && nextEx?.supersetId == exercises[session.currentExerciseIndex].supersetId
                            let titleStr = session.state == .resting ? "COMING UP" : (isSupersetNext ? L.supersetNoRest : "NEXT UP")

                            sectionDivider(title: titleStr)
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
                                    .onDrag {
                                        if idx > session.currentExerciseIndex {
                                            self.draggedExercise = exercise
                                            return NSItemProvider(object: exercise.id.uuidString as NSString)
                                        }
                                        return NSItemProvider()
                                    }
                                    .onDrop(of: [UTType.text], delegate: ActiveWorkoutDropDelegate(
                                        item: exercise,
                                        session: session,
                                        draggedItem: $draggedExercise
                                    ))
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
                            Text(L.endWorkoutUpper)
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
            .simultaneousGesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        handleSwipe(value, session: session, count: exercises.count)
                    }
            )
            .overlay(alignment: .bottom) {
                if let preview = previewIndex, preview != session.currentExerciseIndex {
                    returnPill(session: session)
                        .padding(.bottom, Theme.Spacing.medium)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onChange(of: session.currentExerciseIndex) { _, _ in
                previewIndex = nil
                withAnimation(.easeOut(duration: 0.3)) {
                    scrollProxy.scrollTo("top", anchor: .top)
                }
            }
            .onChange(of: session.state) { _, newState in
                if newState == .resting || newState == .active {
                    // Rest ended or new set started → snap back to the active exercise
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        previewIndex = nil
                    }
                    withAnimation(.easeOut(duration: 0.3)) {
                        scrollProxy.scrollTo("top", anchor: .top)
                    }
                }
            }
            .onChange(of: previewIndex) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    scrollProxy.scrollTo("top", anchor: .top)
                }
            }
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
        .sheet(item: $editSetPayload) { payload in
            EditSetSheet(
                payload: payload,
                onSave: { reps, weight, restSeconds in
                    payload.exercise.updateSet(at: payload.setIndex, reps: reps, weight: weight, restSeconds: restSeconds)
                    editSetPayload = nil
                }
            )
            .presentationDetents([.height(380)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
                    Text(L.endUpper)
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

            Spacer()

            Text(session.plan.name.uppercased())
                .font(Theme.Fonts.label)
                .tracking(2)
                .foregroundStyle(Theme.Colors.textSecondary)
                .lineLimit(1)

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.Layout.cornerRadiusSmall)
            }
            .buttonStyle(.plain)

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



    // MARK: - STATE A: Active Section

    @ViewBuilder
    private func activeSection(session: WorkoutSession, exercises: [Exercise]) -> some View {
        if let exercise = session.currentExercise {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                // EXERCISE HERO HEADER (Image Removed for cleaner look)
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(L.exerciseProgress(session.currentExerciseIndex + 1, exercises.count))
                            .font(Theme.Fonts.label)
                            .tracking(3)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Theme.Colors.surfaceElevated)
                                    .frame(height: 2)
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Theme.Colors.accent)
                                    .frame(width: geo.size.width * (Double(session.currentExerciseIndex + 1) / Double(max(exercises.count, 1))), height: 2)
                            }
                        }
                        .frame(height: 2)
                    }
                    .padding(.bottom, Theme.Spacing.small)

                    if let ssid = exercise.supersetId {
                        Text("SUPERSET • \(ssid)")
                            .font(.system(size: 14, weight: .black))
                            .tracking(2)
                            .foregroundStyle(Theme.Colors.accent)
                    }

                    Text(exercise.displayName.uppercased())
                        .font(.system(size: 30, weight: .black, design: .default))
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L.setsRestMeta(exercise.sets, formatRestTime(exercise.restSeconds)))
                        .font(Theme.Fonts.bodyBold)
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.textSecondary)

                    // Exercise image banner (gpt-image-1 asset, SF Symbol fallback)
                    ZStack {
                        Rectangle()
                            .fill(Theme.Colors.surfaceElevated)

                        if let image = UIImage(named: exercise.imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: exercise.fallbackIcon)
                                .font(.system(size: 36, weight: .thin))
                                .foregroundStyle(Theme.Colors.textSecondary.opacity(0.4))
                        }
                    }
                    .frame(height: 168)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
                    .padding(.top, Theme.Spacing.small)
                }
                .padding(.top, Theme.Spacing.medium)
                .padding(.horizontal, 4)
                
                // SET LIST (Tabular Layout)
                VStack(spacing: 0) {
                    let setsArray = exercise.resolvedSets
                    ForEach(Array(setsArray.enumerated()), id: \.offset) { index, exerciseSet in
                        let setNum = index + 1
                        let isActive = setNum == session.currentSetNumber
                        let isDone = setNum < session.currentSetNumber
                        
                        HStack(spacing: Theme.Spacing.medium) {
                            Button {
                                editSetPayload = EditSetPayload(
                                    exercise: exercise,
                                    setIndex: index,
                                    reps: exerciseSet.reps,
                                    weight: exerciseSet.weight,
                                    restSeconds: exerciseSet.restSeconds ?? exercise.restSeconds
                                )
                            } label: {
                                HStack(spacing: 0) {
                                    // "SATZ 1"
                                    Text(L.setN(setNum))
                                        .font(.system(size: isActive ? 15 : 13, weight: .black))
                                        .foregroundStyle(isActive ? Theme.Colors.accent : Theme.Colors.textSecondary)
                                        .frame(width: 76, alignment: .leading)

                                    VStack(alignment: .leading, spacing: 3) {
                                        // "8 × 35 kg"
                                        Text("\(exerciseSet.reps) × \(exerciseSet.weight > 0 ? exerciseSet.weightFormatted : "—")")
                                            .font(.system(size: isActive ? 23 : 17, weight: isActive ? .bold : .semibold, design: .monospaced))
                                            .foregroundStyle(isActive ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.6)

                                        // "LETZTES MAL · 32,5 KG × 8" (only when a weight was logged)
                                        if isActive, let last = lastSet(for: exercise, index: index), last.weight > 0 {
                                            Text(L.lastTime(formatWeight(last.weight), last.reps))
                                                .font(Theme.Fonts.ghostLabel)
                                                .tracking(0.8)
                                                .foregroundStyle(Theme.Colors.textSecondary.opacity(0.65))
                                                .lineLimit(1)
                                        }
                                    }

                                    Spacer(minLength: 4)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Spacer(minLength: 4)
                            
                            // Checkbox (Action to complete set)
                            Button {
                                if isActive && !manager.isPaused {
                                    HapticService.shared.heavy()
                                    manager.completeSet()
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .strokeBorder(isDone ? Theme.Colors.accent : Theme.Colors.surfaceElevated, lineWidth: 3)
                                        .frame(width: 36, height: 36)
                                    
                                    if isDone {
                                        Circle()
                                            .fill(Theme.Colors.accent)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(!isActive || manager.isPaused)
                        }
                        .padding(.vertical, 18)
                        .padding(.horizontal, Theme.Spacing.large)
                        .background(isActive ? Theme.Colors.surfaceElevated.opacity(0.45) : Color.clear)
                        .overlay(alignment: .leading) {
                            if isActive {
                                Rectangle()
                                    .fill(Theme.Colors.accent)
                                    .frame(width: 3)
                            }
                        }
                        
                        // Separator between rows
                        if setNum < exercise.sets {
                            Rectangle()
                                .fill(Theme.Colors.surface)
                                .frame(height: 1)
                                .padding(.horizontal, Theme.Spacing.large)
                        }
                    }
                    
                    // Add Set Button Row
                    Button {
                        var sets = exercise.resolvedSets
                        let lastSet = sets.last ?? ExerciseSet(index: 1, reps: exercise.reps, weight: exercise.weight)
                        let newSet = ExerciseSet(index: sets.count + 1, reps: lastSet.reps, weight: lastSet.weight)
                        sets.append(newSet)
                        exercise.specificSets = sets
                        exercise.sets = sets.count
                        HapticService.shared.light()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text(L.addSet)
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.large)
                    }
                    .buttonStyle(.plain)
                }
                .background(Theme.Colors.surfaceElevated.opacity(0.1))
                .cornerRadius(Theme.Layout.cornerRadiusLarge)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge)
                        .stroke(Theme.Colors.surface, lineWidth: 1)
                )

                // The old generic "COMPLETE SET" button is removed in favor of the row checkboxes.
                // But we still need an End Workout button prominently here (or at bottom of scrollview).
            }
        }
    }

    private func formatRestTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return secs > 0 ? "\(mins):\(String(format: "%02d", secs)) min" : "\(mins) min"
        }
        return "\(secs) s"
    }

    /// "Letztes Mal" set for the given set index — same-numbered set, falls back to the last one
    private func lastSet(for exercise: Exercise, index: Int) -> CompletedSetData? {
        guard let sets = manager.lastResults[exercise.name], !sets.isEmpty else { return nil }
        return sets.indices.contains(index) ? sets[index] : sets.last
    }

    private func formatWeight(_ weight: Double) -> String {
        WeightDisplay.string(kg: weight, uppercase: true)
    }

    // MARK: - Swipe Browsing (Preview)

    /// Horizontal swipe browses exercises as a preview; the active exercise stays anchored.
    private func handleSwipe(_ value: DragGesture.Value, session: WorkoutSession, count: Int) {
        let dx = value.translation.width
        let dy = value.translation.height
        guard abs(dx) > 60, abs(dx) > abs(dy) * 1.5 else { return }

        let base = previewIndex ?? session.currentExerciseIndex
        let target = dx < 0 ? base + 1 : base - 1
        guard (0..<count).contains(target) else { return }

        HapticService.shared.light()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            previewIndex = target == session.currentExerciseIndex ? nil : target
        }
    }

    @ViewBuilder
    private func previewSection(session: WorkoutSession, exercises: [Exercise], index: Int) -> some View {
        let exercise = exercises[index]
        let isCompleted = index < session.currentExerciseIndex

        VStack(alignment: .leading, spacing: Theme.Spacing.large) {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(isCompleted ? L.previewDone : L.previewExercise(index + 1, exercises.count))
                    .font(Theme.Fonts.label)
                    .tracking(3)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .padding(.bottom, Theme.Spacing.small)

                if let ssid = exercise.supersetId {
                    Text("SUPERSET • \(ssid)")
                        .font(.system(size: 14, weight: .black))
                        .tracking(2)
                        .foregroundStyle(Theme.Colors.accent)
                }

                Text(exercise.displayName.uppercased())
                    .font(.system(size: 30, weight: .black, design: .default))
                    .foregroundStyle(isCompleted ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L.setsRestMeta(exercise.sets, formatRestTime(exercise.restSeconds)))
                    .font(Theme.Fonts.bodyBold)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.textSecondary)

                ZStack {
                    Rectangle()
                        .fill(Theme.Colors.surfaceElevated)

                    if let image = UIImage(named: exercise.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: exercise.fallbackIcon)
                            .font(.system(size: 36, weight: .thin))
                            .foregroundStyle(Theme.Colors.textSecondary.opacity(0.4))
                    }
                }
                .frame(height: 168)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
                .padding(.top, Theme.Spacing.small)
                .opacity(isCompleted ? 0.6 : 1)
            }
            .padding(.top, Theme.Spacing.medium)
            .padding(.horizontal, 4)

            // Read-only set list
            VStack(spacing: 0) {
                let setsArray = exercise.resolvedSets
                ForEach(Array(setsArray.enumerated()), id: \.offset) { idx, exerciseSet in
                    HStack(spacing: Theme.Spacing.medium) {
                        Text(L.setN(idx + 1))
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .frame(width: 76, alignment: .leading)

                        Text("\(exerciseSet.reps) × \(exerciseSet.weight > 0 ? exerciseSet.weightFormatted : "—")")
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Theme.Colors.textSecondary)

                        Spacer()

                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Theme.Colors.accent.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, Theme.Spacing.large)

                    if idx < setsArray.count - 1 {
                        Rectangle()
                            .fill(Theme.Colors.surface)
                            .frame(height: 1)
                            .padding(.horizontal, Theme.Spacing.large)
                    }
                }
            }
            .background(Theme.Colors.surfaceElevated.opacity(0.1))
            .cornerRadius(Theme.Layout.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge)
                    .stroke(Theme.Colors.surface, lineWidth: 1)
            )

            // Deliberate jump — browsing alone never changes the active exercise
            Button {
                HapticService.shared.medium()
                manager.jumpToExercise(index: index)
                previewIndex = nil
            } label: {
                Text(isCompleted ? L.restartExerciseUpper : L.continueHereUpper)
                    .font(Theme.Fonts.label)
                    .tracking(2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Theme.Colors.accent, lineWidth: 1.5)
                    )
                    .foregroundStyle(Theme.Colors.accent)
            }
            .buttonStyle(.plain)
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }

    private func returnPill(session: WorkoutSession) -> some View {
        Button {
            HapticService.shared.light()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                previewIndex = nil
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 8, height: 8)

                Text(L.backToExercise(session.currentExerciseIndex + 1))
                    .font(Theme.Fonts.kicker)
                    .tracking(1.2)
                    .foregroundStyle(Theme.Colors.textPrimary)

                if session.state == .resting {
                    Text(formatRestTimeDigital(session.restTimeRemaining))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.Colors.accent)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Theme.Colors.surfaceElevated)
            .overlay(
                Capsule().stroke(Theme.Colors.accent.opacity(0.4), lineWidth: 1)
            )
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.5), radius: 16, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - STATE B: Rest Section

    @ViewBuilder
    private func restSection(session: WorkoutSession, exercises: [Exercise]) -> some View {
        let exercise = exercises.indices.contains(session.currentExerciseIndex)
            ? exercises[session.currentExerciseIndex] : nil

        let topLabel: String = {
            if let ex = exercise, session.currentSetNumber <= ex.sets {
                return L.restSetN(session.currentSetNumber)
            }
            return L.rest
        }()

        let mainLabel: String = {
            guard let ex = exercise else { return L.finishUpper }
            if session.currentSetNumber <= ex.sets {
                return ex.displayName.uppercased()
            } else if session.currentExerciseIndex + 1 < exercises.count {
                return exercises[session.currentExerciseIndex + 1].displayName.uppercased()
            } else {
                return L.lastSetUpper
            }
        }()

        let nextLabel: String? = {
            guard let ex = exercise else { return nil }
            if session.currentSetNumber <= ex.sets {
                if session.currentExerciseIndex + 1 < exercises.count {
                    return L.then(exercises[session.currentExerciseIndex + 1].displayName.uppercased())
                }
            } else if session.currentExerciseIndex + 2 < exercises.count {
                return L.then(exercises[session.currentExerciseIndex + 2].displayName.uppercased())
            }
            return nil
        }()

        VStack(spacing: Theme.Spacing.xl) {
            // Header
            VStack(spacing: 8) {
                Text(topLabel)
                    .font(Theme.Fonts.label)
                    .tracking(2)
                    .foregroundStyle(Theme.Colors.accent)

                Text(mainLabel)
                    .font(.system(size: 24, weight: .black, design: .default))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)

                if let next = nextLabel {
                    Text(next)
                        .font(Theme.Fonts.kicker)
                        .tracking(2)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            .padding(.top, Theme.Spacing.large)

            // Circular Timer (display only — skipping happens via the button below)
            ZStack {
                Circle()
                    .stroke(Theme.Colors.surfaceElevated, lineWidth: 14)

                Circle()
                    .trim(from: 0, to: CGFloat(session.restTimeRemaining) / CGFloat(max(session.originalRestDuration, 1)))
                    .stroke(Theme.Colors.accent, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: session.restTimeRemaining)

                Text(formatRestTimeDigital(session.restTimeRemaining))
                    .font(.system(size: 60, weight: .bold, design: .default))
                    .foregroundStyle(Theme.Colors.accent)
                    .monospacedDigit()
            }
            .frame(width: 224, height: 224)
            .padding(.vertical, Theme.Spacing.small)

            VStack(spacing: Theme.Spacing.large) {
                HStack(spacing: Theme.Spacing.xl) {
                    Button {
                        manager.adjustRest(by: -15)
                    } label: {
                        Text("−15")
                            .font(Theme.Fonts.label)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(Theme.Colors.surfaceElevated)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Text(L.restRunning)
                        .font(Theme.Fonts.label)
                        .tracking(2)
                        .foregroundStyle(Theme.Colors.textSecondary)

                    Button {
                        manager.adjustRest(by: 15)
                    } label: {
                        Text("+15")
                            .font(Theme.Fonts.label)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(Theme.Colors.surfaceElevated)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    manager.skipRest()
                } label: {
                    Text(L.skip)
                        .font(Theme.Fonts.bodyBold)
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Layout.buttonHeight)
                        .background(Theme.Colors.accent)
                        .foregroundStyle(Theme.Colors.bg)
                        .cornerRadius(Theme.Layout.buttonHeight / 2)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.Spacing.large)
            }
        }
        .padding(.vertical, Theme.Spacing.medium)
    }

    private func formatRestTimeDigital(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    // MARK: - Collapsed Exercise Row (tappable)

    private func collapsedExerciseRow(exercise: Exercise, index: Int, isCompleted: Bool) -> some View {
        Button {
            selectedExerciseIndex = index
        } label: {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                HStack(alignment: .center, spacing: Theme.Spacing.medium) {
                    Circle()
                        .fill(isCompleted ? Theme.Colors.success : Theme.Colors.surfaceElevated)
                        .frame(width: 12, height: 12)

                    if let ssid = exercise.supersetId {
                        Text(ssid.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(Theme.Colors.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Theme.Colors.accent.opacity(0.15))
                            .cornerRadius(4)
                    }

                    Spacer()

                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.surfaceElevated)
                }

                Text(exercise.displayName.uppercased())
                    .font(.system(size: 20, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(isCompleted ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)

                HStack(spacing: Theme.Spacing.small) {
                    Text(L.setsRepsMeta(exercise.sets, exercise.reps))
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)

                    if exercise.weight > 0 {
                        Text("•")
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Text(exercise.weightFormatted)
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all, Theme.Spacing.large)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
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

            Text(L.paused)
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
                .tracking(2)

            Text(L.tapToResume)
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
            Text(L.loading)
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
                .tracking(2)
        }
    }
}

// MARK: - Exercise Index Wrapper

private struct ExerciseIndexWrapper: Identifiable {
    var id: Int { index }
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
                        Text(exercise.displayMuscleGroup.uppercased())
                            .font(Theme.Fonts.caption)
                            .tracking(2)
                            .foregroundStyle(Theme.Colors.accent)
                    }
                    Text(exercise.displayName.uppercased())
                        .font(Theme.Fonts.h2)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .tracking(0.5)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.top, Theme.Spacing.large)

                // Stats row
                HStack(spacing: Theme.Spacing.xl) {
                    statItem(value: "\(exercise.sets)", label: L.setsUpper)
                    statItem(value: "\(exercise.reps)", label: L.repsUpper)
                    if exercise.weight > 0 {
                        statItem(value: exercise.weightFormatted, label: L.weightUpper)
                    }
                    statItem(value: "\(exercise.restSeconds)s", label: L.restUpper)
                }
                .padding(.horizontal, Theme.Spacing.xl)

                Spacer()

                // Actions
                VStack(spacing: Theme.Spacing.medium) {
                    if isCompleted {
                        PrimaryButton(title: L.restartExerciseUpper, icon: "arrow.uturn.left") {
                            onJump()
                        }
                    } else {
                        PrimaryButton(title: L.jumpToExerciseUpper, icon: "arrow.right") {
                            onJump()
                        }

                        SecondaryButton(title: L.markAsDoneUpper, icon: "checkmark.circle") {
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

// MARK: - Edit Set Modal Components

struct EditSetPayload: Identifiable {
    let id = UUID()
    let exercise: Exercise
    let setIndex: Int
    let reps: Int
    let weight: Double
    let restSeconds: Int
}

struct EditSetSheet: View {
    @Environment(\.dismiss) private var dismiss
    let payload: EditSetPayload
    let onSave: (Int, Double, Int) -> Void

    @State private var reps: Int
    @State private var weight: Double
    @State private var restSeconds: Int

    // Picker ranges
    private let repsRange = Array(1...100)
    private let restRange = Array(stride(from: 0, through: 600, by: 15))

    private var unit: WeightUnit { AppSettings.shared.weightUnit }
    /// Selectable weight values in the active unit (kg: 2.5-steps, lb: 5-steps).
    private var weightOptions: [Double] {
        Array(stride(from: unit.step, through: unit.pickerMax, by: unit.step))
    }

    init(payload: EditSetPayload, onSave: @escaping (Int, Double, Int) -> Void) {
        self.payload = payload
        self.onSave = onSave
        _reps = State(initialValue: payload.reps)
        // Snap to a valid option in the active unit so the wheel preselects correctly.
        let u = AppSettings.shared.weightUnit
        let snapped = (u.value(fromKg: payload.weight) / u.step).rounded() * u.step
        _weight = State(initialValue: payload.weight > 0 ? u.kg(fromValue: snapped) : 0)
        _restSeconds = State(initialValue: payload.restSeconds)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.large) {
                    Text(L.editSetN(payload.setIndex + 1))
                        .font(Theme.Fonts.label)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .tracking(1)

                    HStack(spacing: Theme.Spacing.medium) {
                        // Reps Picker
                        VStack {
                            Text(L.repsUpper)
                                .font(Theme.Fonts.caption)
                                .tracking(1)
                                .foregroundStyle(Theme.Colors.textSecondary)
                            
                            Picker("Reps", selection: $reps) {
                                ForEach(repsRange, id: \.self) { num in
                                    Text("\(num)").tag(num)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                        }
                        .padding()
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.Layout.cornerRadiusSmall)

                        // Weight Picker
                        VStack {
                            Text(L.weightUpper)
                                .font(Theme.Fonts.caption)
                                .tracking(1)
                                .foregroundStyle(Theme.Colors.textSecondary)
                            
                            Picker("Weight", selection: $weight) {
                                Text("—").tag(Double(0))
                                ForEach(weightOptions, id: \.self) { v in
                                    Text(v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v)) \(unit.label)" : String(format: "%.1f \(unit.label)", v)).tag(unit.kg(fromValue: v))
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                        }
                        .padding()
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.Layout.cornerRadiusSmall)

                        // Rest Picker
                        VStack {
                            Text(L.restUpper)
                                .font(Theme.Fonts.caption)
                                .tracking(1)
                                .foregroundStyle(Theme.Colors.textSecondary)
                            
                            Picker("Rest", selection: $restSeconds) {
                                ForEach(restRange, id: \.self) { seconds in
                                    Text("\(seconds / 60):\(String(format: "%02d", seconds % 60))").tag(seconds)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                        }
                        .padding()
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.Layout.cornerRadiusSmall)
                    }
                    .padding(.horizontal, Theme.Spacing.large)
                    
                    Spacer()
                }
                .padding(.top, Theme.Spacing.xl)
            }
            .navigationTitle(payload.exercise.displayName.uppercased())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L.cancelUpper) {
                        dismiss()
                    }
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L.saveUpper) {
                        onSave(reps, weight, restSeconds)
                        dismiss()
                    }
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.accent)
                }
            }
        }
    }
}

// MARK: - Active Workout Drop Delegate

struct ActiveWorkoutDropDelegate: DropDelegate {
    let item: Exercise
    let session: WorkoutSession
    @Binding var draggedItem: Exercise?

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        if draggedItem != item {
            var sorted = session.sortedExercises
            guard let from = sorted.firstIndex(of: draggedItem),
                  let to = sorted.firstIndex(of: item) else { return }
            
            // Allow dropping anywhere from currentExerciseIndex onwards
            if from > session.currentExerciseIndex && to >= session.currentExerciseIndex {
                withAnimation(.default) {
                    sorted.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                    for (idx, exercise) in sorted.enumerated() {
                        exercise.orderIndex = idx
                    }
                }
            }
        }
    }
}

#Preview {
    let manager = WorkoutSessionManager()
    ActiveWorkoutView(manager: manager)
}
