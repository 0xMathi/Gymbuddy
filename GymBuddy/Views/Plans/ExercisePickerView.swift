import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ExerciseManager.self) private var exerciseManager

    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    @State private var selectedExercises: Set<UUID> = []

    let onAdd: ([ExerciseDefinition]) -> Void

    private var filteredExercises: [ExerciseDefinition] {
        var results = exerciseManager.allExercises

        // Apply muscle group filter
        if let filter = selectedFilter {
            results = results.filter { $0.muscleGroup == filter }
        }

        // Apply search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.equipment.lowercased().contains(query)
            }
        }

        return results
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter Chips
                    filterChipsView
                        .padding(.top, Theme.Spacing.small)

                    // Exercise List
                    exerciseListView
                }

                // Floating Action Button
                if !selectedExercises.isEmpty {
                    VStack {
                        Spacer()
                        addButton
                            .padding(.horizontal, Theme.Spacing.xl)
                            .padding(.bottom, Theme.Spacing.xl)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            .animation(.spring(response: 0.3), value: selectedExercises.isEmpty)
        }
    }

    // MARK: - Filter Chips

    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.small) {
                // "All" chip
                FilterChip(
                    title: "All",
                    isSelected: selectedFilter == nil,
                    action: { selectedFilter = nil }
                )

                // Muscle group chips
                ForEach(exerciseManager.muscleGroups, id: \.self) { group in
                    FilterChip(
                        title: group,
                        isSelected: selectedFilter == group,
                        action: { selectedFilter = group }
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.small)
        }
    }

    // MARK: - Exercise List

    private var exerciseListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredExercises, id: \.id) { exercise in
                    ExerciseListItem(
                        exercise: exercise,
                        isSelected: selectedExercises.contains(exercise.id),
                        onTap: { toggleSelection(exercise) }
                    )
                }
            }
            .padding(.bottom, selectedExercises.isEmpty ? 0 : 100) // Space for FAB
        }
    }

    // MARK: - Add Button (FAB)

    private var addButton: some View {
        Button(action: addSelectedExercises) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                Text("Add (\(selectedExercises.count)) Exercises")
                    .font(Theme.Fonts.h3)
            }
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Layout.buttonHeight)
            .background(Theme.Colors.accent)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.accent.opacity(0.3), radius: 12, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Actions

    private func toggleSelection(_ exercise: ExerciseDefinition) {
        HapticService.shared.light()
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
    }

    private func addSelectedExercises() {
        HapticService.shared.medium()
        let selected = exerciseManager.allExercises.filter { selectedExercises.contains($0.id) }
        onAdd(selected)
        dismiss()
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticService.shared.light()
            action()
        }) {
            Text(title)
                .font(Theme.Fonts.caption)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.medium)
                .padding(.vertical, Theme.Spacing.small)
                .background(isSelected ? Theme.Colors.surfaceElevated : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Theme.Colors.surfaceElevated, lineWidth: 1)
                )
        }
    }
}

// MARK: - Exercise List Item

struct ExerciseListItem: View {
    let exercise: ExerciseDefinition
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.medium) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.Colors.surfaceElevated)
                        .frame(width: 44, height: 44)

                    Image(systemName: iconForMuscleGroup(exercise.muscleGroup))
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(Theme.Fonts.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Theme.Colors.textPrimary)

                    Text(exercise.muscleGroup.uppercased())
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .tracking(1)
                }

                Spacer()

                // Selection Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.surfaceElevated, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Colors.textPrimary)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.medium)
            .background(isSelected ? Theme.Colors.accentDim : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private func iconForMuscleGroup(_ group: String) -> String {
        switch group {
        case "Brust": return "figure.strengthtraining.traditional"
        case "Rücken": return "figure.rowing"
        case "Schultern": return "figure.arms.open"
        case "Bizeps", "Trizeps": return "figure.strengthtraining.functional"
        case "Beine": return "figure.run"
        case "Gesäß": return "figure.cooldown"
        case "Core": return "figure.core.training"
        case "Ganzkörper": return "figure.highintensity.intervaltraining"
        default: return "dumbbell.fill"
        }
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
    ExercisePickerView { exercises in
        print("Selected: \(exercises.map { $0.name })")
    }
    .environment(ExerciseManager())
}
