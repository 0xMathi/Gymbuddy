import Foundation
import SwiftData
import Observation

@Observable
class ExerciseManager {
    private var modelContext: ModelContext?

    // Cache for quick access
    private(set) var allExercises: [ExerciseDefinition] = []
    private(set) var muscleGroups: [String] = []

    init() {}

    // MARK: - Setup

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        refreshCache()
    }

    private func refreshCache() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<ExerciseDefinition>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            allExercises = try context.fetch(descriptor)
            muscleGroups = Array(Set(allExercises.map { $0.muscleGroup })).sorted()
        } catch {
            print("Failed to fetch exercises: \(error)")
        }
    }

    // MARK: - Search

    /// Search exercises by name, muscle group, or equipment
    func searchExercises(query: String) -> [ExerciseDefinition] {
        guard !query.isEmpty else { return allExercises }

        let lowercasedQuery = query.lowercased()

        return allExercises.filter { exercise in
            exercise.name.lowercased().contains(lowercasedQuery) ||
            exercise.muscleGroup.lowercased().contains(lowercasedQuery) ||
            exercise.equipment.lowercased().contains(lowercasedQuery)
        }
    }

    /// Get exercises by muscle group
    func exercises(for muscleGroup: String) -> [ExerciseDefinition] {
        return allExercises.filter { $0.muscleGroup == muscleGroup }
    }

    /// Get exercises by equipment type
    func exercises(withEquipment equipment: String) -> [ExerciseDefinition] {
        return allExercises.filter { $0.equipment == equipment }
    }

    // MARK: - Create Custom Exercise

    /// Create a new custom exercise
    @discardableResult
    func createCustomExercise(name: String, muscleGroup: String = "Sonstiges", equipment: String = "Sonstiges") -> ExerciseDefinition? {
        guard let context = modelContext else {
            print("ModelContext not configured")
            return nil
        }

        // Check if exercise already exists
        let existingExercise = allExercises.first { $0.name.lowercased() == name.lowercased() }
        if existingExercise != nil {
            print("Exercise '\(name)' already exists")
            return existingExercise
        }

        let newExercise = ExerciseDefinition(
            name: name,
            muscleGroup: muscleGroup,
            equipment: equipment,
            isCustom: true
        )

        context.insert(newExercise)

        do {
            try context.save()
            refreshCache()
            print("Created custom exercise: \(name)")
            return newExercise
        } catch {
            print("Failed to create exercise: \(error)")
            return nil
        }
    }

    // MARK: - Add to Plan

    /// Add an exercise definition to a workout plan
    @discardableResult
    func addExerciseToPlan(
        plan: WorkoutPlan,
        exerciseDef: ExerciseDefinition,
        sets: Int = 3,
        reps: Int = 10,
        weight: Double = 0,
        restSeconds: Int = 90
    ) -> Exercise? {
        guard let context = modelContext else {
            print("ModelContext not configured")
            return nil
        }

        let orderIndex = plan.exercises.count

        let exercise = Exercise(
            from: exerciseDef,
            sets: sets,
            reps: reps,
            weight: weight,
            restSeconds: restSeconds,
            orderIndex: orderIndex
        )

        exercise.plan = plan
        plan.exercises.append(exercise)

        do {
            try context.save()
            print("Added '\(exerciseDef.name)' to plan '\(plan.name)'")
            return exercise
        } catch {
            print("Failed to add exercise to plan: \(error)")
            return nil
        }
    }

    /// Update exercise settings
    func updateExercise(_ exercise: Exercise, sets: Int, reps: Int, weight: Double, restSeconds: Int) {
        guard let context = modelContext else { return }

        exercise.sets = sets
        exercise.reps = reps
        exercise.weight = weight
        exercise.restSeconds = restSeconds

        do {
            try context.save()
        } catch {
            print("Failed to update exercise: \(error)")
        }
    }

    /// Remove an exercise from a workout plan
    func removeExerciseFromPlan(exercise: Exercise, plan: WorkoutPlan) {
        guard let context = modelContext else { return }

        if let index = plan.exercises.firstIndex(where: { $0.id == exercise.id }) {
            plan.exercises.remove(at: index)
            context.delete(exercise)

            // Reorder remaining exercises
            for (index, ex) in plan.exercises.enumerated() {
                ex.orderIndex = index
            }

            do {
                try context.save()
            } catch {
                print("Failed to remove exercise: \(error)")
            }
        }
    }

    /// Reorder exercises in a plan
    func reorderExercises(in plan: WorkoutPlan, from source: IndexSet, to destination: Int) {
        guard let context = modelContext else { return }

        var exercises = plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
        exercises.move(fromOffsets: source, toOffset: destination)

        for (index, exercise) in exercises.enumerated() {
            exercise.orderIndex = index
        }

        do {
            try context.save()
        } catch {
            print("Failed to reorder exercises: \(error)")
        }
    }

    // MARK: - Delete Custom Exercise

    /// Delete a custom exercise definition
    func deleteCustomExercise(_ exercise: ExerciseDefinition) -> Bool {
        guard let context = modelContext else { return false }
        guard exercise.isCustom else {
            print("Cannot delete built-in exercise")
            return false
        }

        context.delete(exercise)

        do {
            try context.save()
            refreshCache()
            return true
        } catch {
            print("Failed to delete exercise: \(error)")
            return false
        }
    }

    // MARK: - Statistics

    var totalExerciseCount: Int { allExercises.count }
    var customExerciseCount: Int { allExercises.filter { $0.isCustom }.count }
    var builtInExerciseCount: Int { allExercises.filter { !$0.isCustom }.count }
}
