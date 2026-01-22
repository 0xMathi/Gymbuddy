import SwiftUI
import SwiftData

struct PlanEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ExerciseManager.self) private var exerciseManager

    @Bindable var plan: WorkoutPlan

    @State private var showExercisePicker = false
    @State private var exerciseToEdit: Exercise?
    @State private var editMode: EditMode = .inactive
    @FocusState private var isNameFocused: Bool

    private var sortedExercises: [Exercise] {
        plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Plan Name Header
                    planNameHeader
                        .padding(.horizontal, Theme.Spacing.large)
                        .padding(.top, Theme.Spacing.medium)

                    if plan.exercises.isEmpty {
                        emptyExercisesView
                    } else {
                        exerciseListView
                    }

                    // Add Exercises Button
                    addExercisesButton
                        .padding(Theme.Spacing.large)
                }
            }
            .navigationTitle("EDIT PLAN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("DONE") {
                        savePlan()
                        dismiss()
                    }
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.accent)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if !plan.exercises.isEmpty {
                        Button(editMode == .active ? "DONE" : "EDIT") {
                            withAnimation {
                                editMode = editMode == .active ? .inactive : .active
                            }
                        }
                        .font(Theme.Fonts.label)
                        .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView { selectedDefinitions in
                    addExercises(selectedDefinitions)
                }
            }
            .sheet(item: $exerciseToEdit) { exercise in
                ExerciseDetailSheet(exercise: exercise) {
                    savePlan()
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Plan Name Header

    private var planNameHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("PLAN NAME")
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.textSecondary)
                .tracking(1.5)

            TextField("MY WORKOUT", text: $plan.name)
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
                .focused($isNameFocused)
                .padding(Theme.Spacing.medium)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.Layout.cornerRadiusSmall)
        }
    }

    // MARK: - Empty State

    private var emptyExercisesView: some View {
        VStack(spacing: Theme.Spacing.large) {
            Spacer()

            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.surfaceElevated)

            VStack(spacing: Theme.Spacing.small) {
                Text("NO EXERCISES YET")
                    .font(Theme.Fonts.h3)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .tracking(1)

                Text("Add exercises to build your workout plan.")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    // MARK: - Exercise List

    private var exerciseListView: some View {
        List {
            ForEach(sortedExercises) { exercise in
                ExerciseRowView(exercise: exercise) {
                    exerciseToEdit = exercise
                }
                .listRowBackground(Theme.Colors.surface)
                .listRowSeparatorTint(Theme.Colors.surfaceElevated)
            }
            .onDelete(perform: deleteExercises)
            .onMove(perform: moveExercises)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Add Button

    private var addExercisesButton: some View {
        Button(action: { showExercisePicker = true }) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                Text("ADD EXERCISES")
                    .font(Theme.Fonts.label)
                    .tracking(1.5)
            }
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Layout.buttonHeight)
            .background(Theme.Colors.accent)
            .cornerRadius(Theme.Layout.cornerRadius)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Actions

    private func addExercises(_ definitions: [ExerciseDefinition]) {
        for definition in definitions {
            exerciseManager.addExerciseToPlan(
                plan: plan,
                exerciseDef: definition,
                sets: 3,
                reps: 10,
                weight: 0,
                restSeconds: 90
            )
        }
    }

    private func deleteExercises(at offsets: IndexSet) {
        let exercisesToDelete = offsets.map { sortedExercises[$0] }
        for exercise in exercisesToDelete {
            exerciseManager.removeExerciseFromPlan(exercise: exercise, plan: plan)
        }
    }

    private func moveExercises(from source: IndexSet, to destination: Int) {
        exerciseManager.reorderExercises(in: plan, from: source, to: destination)
    }

    private func savePlan() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save plan: \(error)")
        }
    }
}

// MARK: - Exercise Row View

struct ExerciseRowView: View {
    @Bindable var exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                // Exercise Name
                Text(exercise.name.uppercased())
                    .font(Theme.Fonts.bodyBold)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .tracking(0.5)

                // Summary Line
                HStack(spacing: Theme.Spacing.medium) {
                    // Sets x Reps
                    HStack(spacing: 4) {
                        Text("\(exercise.sets)")
                            .font(Theme.Fonts.monoLarge)
                            .foregroundStyle(Theme.Colors.accent)
                        Text("×")
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Text("\(exercise.reps)")
                            .font(Theme.Fonts.monoLarge)
                            .foregroundStyle(Theme.Colors.accent)
                    }

                    // Weight
                    if exercise.weight > 0 {
                        Text("@")
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Text(exercise.weightFormatted)
                            .font(Theme.Fonts.mono)
                            .foregroundStyle(Theme.Colors.textPrimary)
                    }

                    Spacer()

                    // Rest Time Badge
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 12, weight: .medium))
                        Text("\(exercise.restSeconds)s")
                            .font(Theme.Fonts.caption)
                    }
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.surfaceElevated)
                    .cornerRadius(8)
                }

                // Muscle Group Tag
                Text(exercise.muscleGroup.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.accent)
            }
            .padding(.vertical, Theme.Spacing.medium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Exercise Detail Sheet

struct ExerciseDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var exercise: Exercise
    let onSave: () -> Void

    // Picker ranges
    private let setsRange = Array(1...10)
    private let repsRange = Array(1...30)
    private let weightRange: [Double] = {
        var weights: [Double] = [0]
        weights += stride(from: 2.5, through: 200, by: 2.5).map { $0 }
        return weights
    }()
    private let restRange = [30, 45, 60, 75, 90, 120, 150, 180, 240, 300]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Exercise Header
                        exerciseHeader

                        // Settings Grid
                        VStack(spacing: Theme.Spacing.large) {
                            // Sets & Reps Row
                            HStack(spacing: Theme.Spacing.medium) {
                                settingCard(
                                    title: "SETS",
                                    value: "\(exercise.sets)",
                                    icon: "repeat"
                                ) {
                                    Picker("Sets", selection: $exercise.sets) {
                                        ForEach(setsRange, id: \.self) { num in
                                            Text("\(num)").tag(num)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 120)
                                }

                                settingCard(
                                    title: "REPS",
                                    value: "\(exercise.reps)",
                                    icon: "arrow.up.arrow.down"
                                ) {
                                    Picker("Reps", selection: $exercise.reps) {
                                        ForEach(repsRange, id: \.self) { num in
                                            Text("\(num)").tag(num)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 120)
                                }
                            }

                            // Weight Card
                            settingCardFull(
                                title: "WEIGHT",
                                value: exercise.weight == 0 ? "—" : String(format: exercise.weight.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f KG" : "%.1f KG", exercise.weight),
                                icon: "scalemass"
                            ) {
                                Picker("Weight", selection: $exercise.weight) {
                                    Text("—").tag(Double(0))
                                    ForEach(weightRange.dropFirst(), id: \.self) { weight in
                                        Text(weight.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(weight)) kg" : String(format: "%.1f kg", weight)).tag(weight)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 120)
                            }

                            // Rest Time Card
                            settingCardFull(
                                title: "REST TIME",
                                value: formatRestTime(exercise.restSeconds),
                                icon: "timer"
                            ) {
                                Picker("Rest", selection: $exercise.restSeconds) {
                                    ForEach(restRange, id: \.self) { seconds in
                                        Text(formatRestTime(seconds)).tag(seconds)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 120)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.large)
                    }
                    .padding(.vertical, Theme.Spacing.large)
                }
            }
            .navigationTitle("EXERCISE DETAILS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("CANCEL") {
                        dismiss()
                    }
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("SAVE") {
                        onSave()
                        dismiss()
                    }
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.accent)
                }
            }
        }
    }

    // MARK: - Exercise Header

    private var exerciseHeader: some View {
        VStack(spacing: Theme.Spacing.small) {
            Text(exercise.name.uppercased())
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
                .tracking(1)
                .multilineTextAlignment(.center)

            Text(exercise.muscleGroup.uppercased())
                .font(Theme.Fonts.label)
                .foregroundStyle(Theme.Colors.accent)
                .tracking(1.5)
        }
        .padding(.horizontal, Theme.Spacing.large)
        .padding(.top, Theme.Spacing.medium)
    }

    // MARK: - Setting Cards

    @ViewBuilder
    private func settingCard<Content: View>(
        title: String,
        value: String,
        icon: String,
        @ViewBuilder picker: () -> Content
    ) -> some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(Theme.Fonts.label)
                    .tracking(1)
            }
            .foregroundStyle(Theme.Colors.textSecondary)

            Text(value)
                .font(Theme.Fonts.hero)
                .foregroundStyle(Theme.Colors.accent)

            picker()
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.large)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }

    @ViewBuilder
    private func settingCardFull<Content: View>(
        title: String,
        value: String,
        icon: String,
        @ViewBuilder picker: () -> Content
    ) -> some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(Theme.Fonts.label)
                    .tracking(1)
                Spacer()
                Text(value)
                    .font(Theme.Fonts.h1)
                    .foregroundStyle(Theme.Colors.accent)
            }
            .foregroundStyle(Theme.Colors.textSecondary)

            picker()
        }
        .padding(Theme.Spacing.large)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }

    private func formatRestTime(_ seconds: Int) -> String {
        if seconds >= 60 {
            let mins = seconds / 60
            let secs = seconds % 60
            if secs == 0 {
                return "\(mins) MIN"
            } else {
                return "\(mins):\(String(format: "%02d", secs))"
            }
        }
        return "\(seconds) SEC"
    }
}

// MARK: - Scale Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutPlan.self, configurations: config)
    let plan = WorkoutPlan(name: "Push Day")
    container.mainContext.insert(plan)

    return PlanEditView(plan: plan)
        .modelContainer(container)
        .environment(ExerciseManager())
}
