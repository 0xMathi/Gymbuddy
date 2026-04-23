import Foundation
import SwiftData

// MARK: - PPL Plan Seed Data

private struct PlanExerciseSeed {
    let exerciseName: String
    let sets: Int
    let reps: Int
    let restSeconds: Int
    var supersetId: String? = nil
}

private struct PlanSeed {
    let name: String
    let orderIndex: Int
    let exercises: [PlanExerciseSeed]
}

// MARK: - Default Superset Plans

private let defaultPPLPlans: [PlanSeed] = [
    // MARK: Montag (Push-Pull)
    PlanSeed(name: "Montag (Schwer)", orderIndex: 0, exercises: [
        PlanExerciseSeed(exerciseName: "Kurzhantel-Bankdrücken", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Kurzhantel-Rudern", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Schrägbankdrücken", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Klimmzüge", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Rumänisches Kreuzheben", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Langhantel-Rudern", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Seitheben", sets: 3, reps: 15, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Face Pulls", sets: 3, reps: 15, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Kabelzug-Curls", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER"),
        PlanExerciseSeed(exerciseName: "Trizepsdrücken am Kabel", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER")
    ]),

    // MARK: Mittwoch (Hypertrophie)
    PlanSeed(name: "Mittwoch (Hypertrophie)", orderIndex: 1, exercises: [
        PlanExerciseSeed(exerciseName: "Beinstrecker", sets: 4, reps: 12, restSeconds: 75, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Beinbeuger", sets: 4, reps: 12, restSeconds: 75, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Frontkniebeugen", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Ausfallschritte", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Kurzhantel-Flys", sets: 3, reps: 12, restSeconds: 75, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Kurzhantel-Rudern", sets: 3, reps: 12, restSeconds: 75, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Ausfallschritte", sets: 3, reps: 10, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Wadenheben stehend", sets: 3, reps: 15, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Kurzhantel-Curls", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER"),
        PlanExerciseSeed(exerciseName: "Trizepsdrücken am Kabel", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER")
    ]),

    // MARK: Freitag (Power)
    PlanSeed(name: "Freitag (Power)", orderIndex: 2, exercises: [
        PlanExerciseSeed(exerciseName: "Kurzhantel-Bankdrücken", sets: 4, reps: 8, restSeconds: 120, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Kreuzheben", sets: 4, reps: 8, restSeconds: 120, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Kniebeugen", sets: 4, reps: 8, restSeconds: 120, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "T-Bar Rudern", sets: 4, reps: 8, restSeconds: 120, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Kurzhantel-Schulterdrücken", sets: 3, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Latzug", sets: 3, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Ausfallschritte", sets: 3, reps: 8, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Seitheben", sets: 3, reps: 12, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Dips (Brust)", sets: 2, reps: 8, restSeconds: 60, supersetId: "FINISHER"),
        PlanExerciseSeed(exerciseName: "Kettlebell Swings", sets: 2, reps: 15, restSeconds: 60, supersetId: "FINISHER")
    ]),
]

// MARK: - PPL Plan Names (for validation)

private let pplPlanNames = Set(defaultPPLPlans.map { $0.name })

// MARK: - Seeder Function

func seedDefaultPlans(modelContext: ModelContext) {
    // Step 1: Cleanup old/invalid plans (one-time migration)
    cleanupInvalidPlans(modelContext: modelContext)

    // Step 2: Fetch all exercise definitions for lookup
    let definitionDescriptor = FetchDescriptor<ExerciseDefinition>()
    guard let definitions = try? modelContext.fetch(definitionDescriptor), !definitions.isEmpty else {
        print("No exercise definitions found - skipping plan seeding")
        return
    }
    let definitionsByName = Dictionary(uniqueKeysWithValues: definitions.map { ($0.name, $0) })

    // Step 3: Check and create each PPL plan individually
    for planSeed in defaultPPLPlans {
        if !planExists(named: planSeed.name, in: modelContext) {
            createPlan(from: planSeed, definitions: definitionsByName, modelContext: modelContext)
        }
    }

    // Step 4: Save all changes
    do {
        try modelContext.save()
        print("PPL plan seeding completed")
    } catch {
        print("Failed to save PPL plans: \(error)")
    }
}

// MARK: - Helper Functions

private func planExists(named name: String, in modelContext: ModelContext) -> Bool {
    var descriptor = FetchDescriptor<WorkoutPlan>(
        predicate: #Predicate { $0.name == name }
    )
    descriptor.fetchLimit = 1

    do {
        let count = try modelContext.fetchCount(descriptor)
        return count > 0
    } catch {
        print("Failed to check if plan '\(name)' exists: \(error)")
        return false
    }
}

private func createPlan(
    from seed: PlanSeed,
    definitions: [String: ExerciseDefinition],
    modelContext: ModelContext
) {
    let plan = WorkoutPlan(name: seed.name, orderIndex: seed.orderIndex)
    modelContext.insert(plan)

    // Add exercises with Copy-on-Write pattern
    for (index, exerciseSeed) in seed.exercises.enumerated() {
        guard let definition = definitions[exerciseSeed.exerciseName] else {
            print("Warning: Exercise '\(exerciseSeed.exerciseName)' not found in definitions")
            continue
        }

        let exercise = Exercise(
            from: definition,
            sets: exerciseSeed.sets,
            reps: exerciseSeed.reps,
            weight: 0,
            restSeconds: exerciseSeed.restSeconds,
            orderIndex: index,
            supersetId: exerciseSeed.supersetId
        )

        exercise.plan = plan
        modelContext.insert(exercise)
    }

    print("Created plan: \(seed.name) with \(seed.exercises.count) exercises")
}

private func cleanupInvalidPlans(modelContext: ModelContext) {
    let descriptor = FetchDescriptor<WorkoutPlan>()
    guard let allPlans = try? modelContext.fetch(descriptor) else { return }

    // Step A: collect obviously invalid plans to delete
    var toDelete: [WorkoutPlan] = []
    for plan in allPlans {
        if plan.name == "New Plan" {
            toDelete.append(plan)
        } else if plan.name == "Push" || plan.name == "Pull" || plan.name == "Legs" {
            toDelete.append(plan)
        } else if plan.name.hasPrefix("Tag ") && plan.name.contains(" – ") {
            // Old German-named PPL plans ("Tag 1 – PUSH", "Tag 2 – PULL", "Tag 3 – LEGS")
            toDelete.append(plan)
        } else if plan.exercises.isEmpty && !pplPlanNames.contains(plan.name) {
            toDelete.append(plan)
        }
    }
    for plan in toDelete {
        modelContext.delete(plan)
        print("Cleaned up invalid plan: '\(plan.name)'")
    }

    // Step B: deduplicate by name — keep the one with the most exercises
    let remaining = allPlans.filter { !toDelete.contains($0) }
    let grouped = Dictionary(grouping: remaining, by: { $0.name })
    for (name, dupes) in grouped where dupes.count > 1 {
        let sorted = dupes.sorted { $0.exercises.count > $1.exercises.count }
        for dupe in sorted.dropFirst() {
            modelContext.delete(dupe)
            print("Removed duplicate plan: '\(name)'")
        }
    }

    let totalRemoved = toDelete.count + grouped.values.reduce(0) { $0 + max($1.count - 1, 0) }
    if totalRemoved > 0 {
        print("Cleanup: Removed \(totalRemoved) invalid/duplicate plan(s)")
    }
}
