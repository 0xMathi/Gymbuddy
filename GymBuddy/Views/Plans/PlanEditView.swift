import SwiftUI
import SwiftData

struct PlanEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ExerciseManager.self) private var exerciseManager

    @Bindable var plan: WorkoutPlan

    @State private var showExercisePicker = false
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
            .navigationTitle("Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        savePlan()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.Colors.accent)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if !plan.exercises.isEmpty {
                        Button(editMode == .active ? "Done" : "Edit") {
                            withAnimation {
                                editMode = editMode == .active ? .inactive : .active
                            }
                        }
                        .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView { selectedDefinitions in
                    addExercises(selectedDefinitions)
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Plan Name Header

    private var planNameHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("PLAN NAME")
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
                .tracking(1)

            TextField("My Workout", text: $plan.name)
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
                .focused($isNameFocused)
                .padding(Theme.Spacing.medium)
                .background(Theme.Colors.surface)
                .cornerRadius(12)
        }
    }

    // MARK: - Empty State

    private var emptyExercisesView: some View {
        VStack(spacing: Theme.Spacing.large) {
            Spacer()

            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Colors.surfaceElevated)

            VStack(spacing: Theme.Spacing.small) {
                Text("No Exercises Yet")
                    .font(Theme.Fonts.h3)
                    .foregroundStyle(Theme.Colors.textPrimary)

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
                ExerciseRowView(exercise: exercise)
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
                    .font(.system(size: 18, weight: .semibold))
                Text("Add Exercises")
                    .font(Theme.Fonts.h3)
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

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            // Exercise Name
            Text(exercise.name)
                .font(Theme.Fonts.body)
                .fontWeight(.medium)
                .foregroundStyle(Theme.Colors.textPrimary)

            // Details
            HStack(spacing: Theme.Spacing.medium) {
                // Sets
                HStack(spacing: 4) {
                    Image(systemName: "repeat")
                        .font(.system(size: 12))
                    Text("\(exercise.sets) Sets")
                }

                // Rest
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 12))
                    Text("\(exercise.restSeconds)s Rest")
                }

                // Muscle Group
                Text(exercise.muscleGroup.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.Colors.surfaceElevated)
                    .cornerRadius(4)
            }
            .font(Theme.Fonts.caption)
            .foregroundStyle(Theme.Colors.textSecondary)
        }
        .padding(.vertical, Theme.Spacing.small)
    }
}

// MARK: - Scale Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
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
