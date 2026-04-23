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
    PlanSeed(name: "MONTAG — Schwerer Tag (Push-Pull)", orderIndex: 0, exercises: [
        PlanExerciseSeed(exerciseName: "KH-Bankdrücken", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Einarmiges KH-Rudern", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Schrägbankdrücken KH", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Klimmzüge", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Rumänisches Kreuzheben", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Langhantel-Rudern stehend", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Kabelzug-Seitenheben", sets: 3, reps: 15, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Face Pulls", sets: 3, reps: 15, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Kabel-Bizeps-Curls", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER"),
        PlanExerciseSeed(exerciseName: "Kabel-Overhead-Trizeps", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER")
    ]),

    // MARK: Mittwoch (Hypertrophie)
    PlanSeed(name: "MITTWOCH — Hypertrophie-Tag", orderIndex: 1, exercises: [
        PlanExerciseSeed(exerciseName: "Kniebeuge Langhantel", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Ausfallschritte KH", sets: 4, reps: 10, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "Beinstrecker", sets: 4, reps: 12, restSeconds: 75, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Beinbeuger", sets: 4, reps: 12, restSeconds: 75, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Hip Thrusts", sets: 3, reps: 12, restSeconds: 60, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Wadenheben stehend", sets: 3, reps: 15, restSeconds: 60, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "KH-Bankdrücken", sets: 3, reps: 12, restSeconds: 75, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Einarmiges KH-Rudern", sets: 3, reps: 12, restSeconds: 75, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Bizeps-Curls KH", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER"),
        PlanExerciseSeed(exerciseName: "Trizeps-Drücken Seil", sets: 3, reps: 15, restSeconds: 60, supersetId: "FINISHER")
    ]),

    // MARK: Freitag (Power)
    PlanSeed(name: "FREITAG — Power-Tag", orderIndex: 2, exercises: [
        PlanExerciseSeed(exerciseName: "Kniebeuge Langhantel", sets: 4, reps: 8, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "T-Bar Rudern", sets: 4, reps: 8, restSeconds: 90, supersetId: "SS1"),
        PlanExerciseSeed(exerciseName: "KH-Bankdrücken", sets: 4, reps: 8, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Kreuzheben", sets: 4, reps: 8, restSeconds: 90, supersetId: "SS2"),
        PlanExerciseSeed(exerciseName: "Schulterdrücken KH", sets: 3, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Face Pulls", sets: 3, reps: 10, restSeconds: 90, supersetId: "SS3"),
        PlanExerciseSeed(exerciseName: "Ausfallschritte KH", sets: 3, reps: 8, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Wadenheben stehend", sets: 3, reps: 15, restSeconds: 60, supersetId: "SS4"),
        PlanExerciseSeed(exerciseName: "Dips", sets: 2, reps: 8, restSeconds: 60, supersetId: "FINISHER"),
        PlanExerciseSeed(exerciseName: "Hanging Leg Raises", sets: 2, reps: 12, restSeconds: 60, supersetId: "FINISHER")
    ]),
]

// MARK: - PPL Plan Names (for validation)

private let pplPlanNames = Set(defaultPPLPlans.map { $0.name })

// MARK: - Seeder Function

func seedDefaultPlans(modelContext: ModelContext) {
    // Step 0: Migrate old exercise names to exact screenshot names
    migrateExerciseNames(modelContext: modelContext)

    // Step 1: Cleanup old/invalid plans (one-time migration)
    cleanupInvalidPlans(modelContext: modelContext)

    // Step 2: Fetch all exercise definitions for lookup
    let definitionDescriptor = FetchDescriptor<ExerciseDefinition>()
    guard let definitions = try? modelContext.fetch(definitionDescriptor), !definitions.isEmpty else {
        print("No exercise definitions found - skipping plan seeding")
        return
    }
    var definitionsByName = Dictionary(uniqueKeysWithValues: definitions.map { ($0.name, $0) })

    // Step 3: Check and create each PPL plan individually
    for planSeed in defaultPPLPlans {
        if !planExists(named: planSeed.name, in: modelContext) {
            createPlan(from: planSeed, definitions: &definitionsByName, modelContext: modelContext)
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
    definitions: inout [String: ExerciseDefinition],
    modelContext: ModelContext
) {
    let plan = WorkoutPlan(name: seed.name, orderIndex: seed.orderIndex)
    modelContext.insert(plan)

    // Add exercises with Copy-on-Write pattern
    for (index, exerciseSeed) in seed.exercises.enumerated() {
        var definition = definitions[exerciseSeed.exerciseName]
        if definition == nil {
            print("Auto-creating missing exercise: '\(exerciseSeed.exerciseName)'")
            let newDef = ExerciseDefinition(name: exerciseSeed.exerciseName, muscleGroup: "Sonstiges", equipment: "Sonstiges", isCustom: false)
            modelContext.insert(newDef)
            definitions[exerciseSeed.exerciseName] = newDef
            definition = newDef
        }

        guard let validDef = definition else { continue }

        let exercise = Exercise(
            from: validDef,
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
        } else if plan.name == "Montag (Schwer)" || plan.name == "Mittwoch (Hypertrophie)" || plan.name == "Freitag (Power)" {
            // Delete the old default plans to make way for the new exact ones
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

private func migrateExerciseNames(modelContext: ModelContext) {
    let renameMap: [String: String] = [
        "Kurzhantel-Bankdrücken": "KH-Bankdrücken",
        "Kurzhantel-Rudern": "Einarmiges KH-Rudern",
        "Schrägbankdrücken": "Schrägbankdrücken KH",
        "Langhantel-Rudern": "Langhantel-Rudern stehend",
        "Seitheben": "Kabelzug-Seitenheben",
        "Kabelzug-Curls": "Kabel-Bizeps-Curls",
        "Trizepsdrücken am Kabel": "Kabel-Overhead-Trizeps",
        "Kniebeugen": "Kniebeuge Langhantel",
        "Kurzhantel-Schulterdrücken": "Schulterdrücken KH",
        "Ausfallschritte": "Ausfallschritte KH",
        "Dips (Brust)": "Dips",
        "Beinheben hängend": "Hanging Leg Raises",
        "Kurzhantel-Curls": "Bizeps-Curls KH"
    ]
    
    let descriptor = FetchDescriptor<ExerciseDefinition>()
    guard let definitions = try? modelContext.fetch(descriptor) else { return }
    
    for definition in definitions {
        if let newName = renameMap[definition.name] {
            definition.name = newName
        }
    }
    
    let existingNames = Set(definitions.map { $0.name })
    if !existingNames.contains("Trizeps-Drücken Seil") {
        let newDef = ExerciseDefinition(name: "Trizeps-Drücken Seil", muscleGroup: "Trizeps", equipment: "Kabelzug", isCustom: false)
        modelContext.insert(newDef)
    }
    
    try? modelContext.save()
}
