import Foundation
import SwiftData

// MARK: - Starter Plan Seed Data
//
// Generic Push/Pull/Legs starter templates shipped to new users.
// (The developer's personal plans are archived in docs/personal-plans-backup.json.)
// Exercise names match ExerciseSeed definitions and have matching image assets.

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

private let starterPlans: [PlanSeed] = [
    PlanSeed(name: "Push Day", orderIndex: 0, exercises: [
        PlanExerciseSeed(exerciseName: "Bankdrücken", sets: 4, reps: 8, restSeconds: 120),
        PlanExerciseSeed(exerciseName: "Schrägbankdrücken", sets: 3, reps: 10, restSeconds: 90),
        PlanExerciseSeed(exerciseName: "Schulterdrücken", sets: 3, reps: 10, restSeconds: 90),
        PlanExerciseSeed(exerciseName: "Kurzhantel-Flys", sets: 3, reps: 12, restSeconds: 60),
        PlanExerciseSeed(exerciseName: "Seitheben", sets: 3, reps: 15, restSeconds: 45),
        PlanExerciseSeed(exerciseName: "Trizepsdrücken am Kabel", sets: 3, reps: 12, restSeconds: 60),
    ]),

    PlanSeed(name: "Pull Day", orderIndex: 1, exercises: [
        PlanExerciseSeed(exerciseName: "Klimmzüge", sets: 4, reps: 8, restSeconds: 120),
        PlanExerciseSeed(exerciseName: "Langhantel-Rudern", sets: 4, reps: 8, restSeconds: 90),
        PlanExerciseSeed(exerciseName: "Kabelrudern", sets: 3, reps: 12, restSeconds: 75),
        PlanExerciseSeed(exerciseName: "Face Pulls", sets: 3, reps: 15, restSeconds: 45),
        PlanExerciseSeed(exerciseName: "Langhantel-Curls", sets: 3, reps: 10, restSeconds: 60),
        PlanExerciseSeed(exerciseName: "Hammer Curls", sets: 3, reps: 12, restSeconds: 45),
    ]),

    PlanSeed(name: "Leg Day", orderIndex: 2, exercises: [
        PlanExerciseSeed(exerciseName: "Kniebeugen", sets: 4, reps: 8, restSeconds: 150),
        PlanExerciseSeed(exerciseName: "Rumänisches Kreuzheben", sets: 3, reps: 10, restSeconds: 120),
        PlanExerciseSeed(exerciseName: "Beinpresse", sets: 3, reps: 12, restSeconds: 90),
        PlanExerciseSeed(exerciseName: "Beinbeuger", sets: 3, reps: 12, restSeconds: 60),
        PlanExerciseSeed(exerciseName: "Beinstrecker", sets: 3, reps: 15, restSeconds: 60),
        PlanExerciseSeed(exerciseName: "Wadenheben stehend", sets: 4, reps: 15, restSeconds: 45),
    ]),
]

// MARK: - Seeder

/// Seeds the generic starter plans on first launch only.
/// Existing installs (flag already set) keep all of their own data untouched.
func seedDefaultPlans(modelContext: ModelContext) {
    let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededDefaultPlans")
    guard !hasSeeded else { return }

    let definitionDescriptor = FetchDescriptor<ExerciseDefinition>()
    guard let definitions = try? modelContext.fetch(definitionDescriptor), !definitions.isEmpty else {
        // Exercise library not ready yet — try again on the next launch (don't set the flag).
        print("No exercise definitions found - skipping plan seeding")
        return
    }
    var definitionsByName = Dictionary(definitions.map { ($0.name, $0) }, uniquingKeysWith: { a, _ in a })

    for planSeed in starterPlans where !planExists(named: planSeed.name, in: modelContext) {
        createPlan(from: planSeed, definitions: &definitionsByName, modelContext: modelContext)
    }

    do {
        try modelContext.save()
        UserDefaults.standard.set(true, forKey: "hasSeededDefaultPlans")
        print("Starter plan seeding completed")
    } catch {
        print("Failed to save starter plans: \(error)")
    }
}

// MARK: - Helpers

private func planExists(named name: String, in modelContext: ModelContext) -> Bool {
    var descriptor = FetchDescriptor<WorkoutPlan>(predicate: #Predicate { $0.name == name })
    descriptor.fetchLimit = 1
    return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
}

private func createPlan(
    from seed: PlanSeed,
    definitions: inout [String: ExerciseDefinition],
    modelContext: ModelContext
) {
    let plan = WorkoutPlan(name: seed.name, orderIndex: seed.orderIndex)
    modelContext.insert(plan)

    for (index, exerciseSeed) in seed.exercises.enumerated() {
        let definition: ExerciseDefinition
        if let existing = definitions[exerciseSeed.exerciseName] {
            definition = existing
        } else {
            // Safety fallback — should not happen for starter plans, but never crash.
            print("Auto-creating missing exercise: '\(exerciseSeed.exerciseName)'")
            let newDef = ExerciseDefinition(name: exerciseSeed.exerciseName, muscleGroup: "Sonstiges", equipment: "Sonstiges", isCustom: false)
            modelContext.insert(newDef)
            definitions[exerciseSeed.exerciseName] = newDef
            definition = newDef
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
}
