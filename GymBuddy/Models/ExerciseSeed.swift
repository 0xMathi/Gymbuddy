import Foundation
import SwiftData

struct ExerciseSeedData {
    let name: String
    let muscleGroup: String
    let equipment: String
    var wgerBaseId: Int? = nil
}

// MARK: - wger.de Exercise ID Mapping
// Source: https://wger.de/api/v2/exerciseinfo/?format=json&language=2
private let wgerIdMap: [String: Int] = [
    "Bankdrücken": 192,
    "Schrägbankdrücken": 234,
    "Kurzhantel-Flys": 68,
    "Schulterdrücken": 69,
    "Seitheben": 78,
    "Trizepsdrücken am Kabel": 81,
    "Skull Crushers": 112,
    "Kreuzheben": 184,
    "Klimmzüge": 475,
    "Langhantel-Rudern": 90,
    "Kabelrudern": 91,
    "Face Pulls": 254,
    "Langhantel-Curls": 85,
    "Hammer Curls": 88,
    "Kniebeugen": 111,
    "Rumänisches Kreuzheben": 193,
    "Beinpresse": 105,
    "Beinstrecker": 225,
    "Beinbeuger": 110,
    "Wadenheben stehend": 156,
]

// MARK: - Default Exercise Library
let defaultExercises: [ExerciseSeedData] = defaultExercisesRaw.map { seed in
    var s = seed
    s.wgerBaseId = wgerIdMap[seed.name]
    return s
}

private let defaultExercisesRaw: [ExerciseSeedData] = [
    // MARK: Brust (Chest)
    ExerciseSeedData(name: "Bankdrücken", muscleGroup: "Brust", equipment: "Langhantel"),
    ExerciseSeedData(name: "Schrägbankdrücken", muscleGroup: "Brust", equipment: "Langhantel"),
    ExerciseSeedData(name: "Kurzhantel-Bankdrücken", muscleGroup: "Brust", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Kurzhantel-Flys", muscleGroup: "Brust", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Cable-Crossover", muscleGroup: "Brust", equipment: "Kabelzug"),
    ExerciseSeedData(name: "Liegestütze", muscleGroup: "Brust", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Dips (Brust)", muscleGroup: "Brust", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Butterfly-Maschine", muscleGroup: "Brust", equipment: "Maschine"),

    // MARK: Rücken (Back)
    ExerciseSeedData(name: "Kreuzheben", muscleGroup: "Rücken", equipment: "Langhantel"),
    ExerciseSeedData(name: "Klimmzüge", muscleGroup: "Rücken", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Langhantel-Rudern", muscleGroup: "Rücken", equipment: "Langhantel"),
    ExerciseSeedData(name: "Kurzhantel-Rudern", muscleGroup: "Rücken", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Latzug", muscleGroup: "Rücken", equipment: "Kabelzug"),
    ExerciseSeedData(name: "Kabelrudern", muscleGroup: "Rücken", equipment: "Kabelzug"),
    ExerciseSeedData(name: "T-Bar Rudern", muscleGroup: "Rücken", equipment: "Langhantel"),
    ExerciseSeedData(name: "Face Pulls", muscleGroup: "Rücken", equipment: "Kabelzug"),

    // MARK: Schultern (Shoulders)
    ExerciseSeedData(name: "Schulterdrücken", muscleGroup: "Schultern", equipment: "Langhantel"),
    ExerciseSeedData(name: "Kurzhantel-Schulterdrücken", muscleGroup: "Schultern", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Seitheben", muscleGroup: "Schultern", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Frontheben", muscleGroup: "Schultern", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Arnold Press", muscleGroup: "Schultern", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Aufrechtes Rudern", muscleGroup: "Schultern", equipment: "Langhantel"),
    ExerciseSeedData(name: "Reverse Flys", muscleGroup: "Schultern", equipment: "Kurzhantel"),

    // MARK: Bizeps (Biceps)
    ExerciseSeedData(name: "Langhantel-Curls", muscleGroup: "Bizeps", equipment: "Langhantel"),
    ExerciseSeedData(name: "Kurzhantel-Curls", muscleGroup: "Bizeps", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Hammer Curls", muscleGroup: "Bizeps", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Preacher Curls", muscleGroup: "Bizeps", equipment: "Langhantel"),
    ExerciseSeedData(name: "Kabelzug-Curls", muscleGroup: "Bizeps", equipment: "Kabelzug"),
    ExerciseSeedData(name: "Konzentrations-Curls", muscleGroup: "Bizeps", equipment: "Kurzhantel"),

    // MARK: Trizeps (Triceps)
    ExerciseSeedData(name: "Trizeps-Dips", muscleGroup: "Trizeps", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Trizepsdrücken am Kabel", muscleGroup: "Trizeps", equipment: "Kabelzug"),
    ExerciseSeedData(name: "Skull Crushers", muscleGroup: "Trizeps", equipment: "Langhantel"),
    ExerciseSeedData(name: "Overhead Trizeps Extension", muscleGroup: "Trizeps", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Enges Bankdrücken", muscleGroup: "Trizeps", equipment: "Langhantel"),
    ExerciseSeedData(name: "Kickbacks", muscleGroup: "Trizeps", equipment: "Kurzhantel"),

    // MARK: Beine (Legs)
    ExerciseSeedData(name: "Kniebeugen", muscleGroup: "Beine", equipment: "Langhantel"),
    ExerciseSeedData(name: "Frontkniebeugen", muscleGroup: "Beine", equipment: "Langhantel"),
    ExerciseSeedData(name: "Beinpresse", muscleGroup: "Beine", equipment: "Maschine"),
    ExerciseSeedData(name: "Ausfallschritte", muscleGroup: "Beine", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Bulgarische Split Squats", muscleGroup: "Beine", equipment: "Kurzhantel"),
    ExerciseSeedData(name: "Beinstrecker", muscleGroup: "Beine", equipment: "Maschine"),
    ExerciseSeedData(name: "Beinbeuger", muscleGroup: "Beine", equipment: "Maschine"),
    ExerciseSeedData(name: "Wadenheben stehend", muscleGroup: "Beine", equipment: "Maschine"),
    ExerciseSeedData(name: "Wadenheben sitzend", muscleGroup: "Beine", equipment: "Maschine"),
    ExerciseSeedData(name: "Rumänisches Kreuzheben", muscleGroup: "Beine", equipment: "Langhantel"),

    // MARK: Gesäß (Glutes)
    ExerciseSeedData(name: "Hip Thrusts", muscleGroup: "Gesäß", equipment: "Langhantel"),
    ExerciseSeedData(name: "Glute Bridge", muscleGroup: "Gesäß", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Cable Pull-Through", muscleGroup: "Gesäß", equipment: "Kabelzug"),
    ExerciseSeedData(name: "Sumo Kreuzheben", muscleGroup: "Gesäß", equipment: "Langhantel"),

    // MARK: Core
    ExerciseSeedData(name: "Planke", muscleGroup: "Core", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Crunches", muscleGroup: "Core", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Beinheben hängend", muscleGroup: "Core", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Russian Twists", muscleGroup: "Core", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Ab-Rollout", muscleGroup: "Core", equipment: "Sonstiges"),
    ExerciseSeedData(name: "Kabelzug-Crunches", muscleGroup: "Core", equipment: "Kabelzug"),

    // MARK: Ganzkörper (Full Body)
    ExerciseSeedData(name: "Thrusters", muscleGroup: "Ganzkörper", equipment: "Langhantel"),
    ExerciseSeedData(name: "Clean & Press", muscleGroup: "Ganzkörper", equipment: "Langhantel"),
    ExerciseSeedData(name: "Kettlebell Swings", muscleGroup: "Ganzkörper", equipment: "Kettlebell"),
    ExerciseSeedData(name: "Burpees", muscleGroup: "Ganzkörper", equipment: "Körpergewicht"),
    ExerciseSeedData(name: "Turkish Get-Up", muscleGroup: "Ganzkörper", equipment: "Kettlebell"),
]

// MARK: - Seeder Function
func seedDefaultExercises(modelContext: ModelContext) {
    // Check if we already have exercises
    let descriptor = FetchDescriptor<ExerciseDefinition>()

    do {
        let existingCount = try modelContext.fetchCount(descriptor)

        // Only seed if database is empty
        guard existingCount == 0 else {
            print("Database already seeded with \(existingCount) exercises")
            return
        }

        // Insert all default exercises
        for exerciseData in defaultExercises {
            let exercise = ExerciseDefinition(
                name: exerciseData.name,
                muscleGroup: exerciseData.muscleGroup,
                equipment: exerciseData.equipment,
                isCustom: false
            )
            exercise.wgerBaseId = exerciseData.wgerBaseId
            modelContext.insert(exercise)
        }

        // Save context
        try modelContext.save()
        print("Successfully seeded \(defaultExercises.count) exercises")

    } catch {
        print("Failed to seed exercises: \(error)")
    }
}

// MARK: - Patch wger IDs for existing Exercise objects (Copy-on-Write in WorkoutPlans)
func patchExerciseWgerIds(modelContext: ModelContext) {
    let descriptor = FetchDescriptor<Exercise>()
    guard let exercises = try? modelContext.fetch(descriptor) else { return }

    var patched = 0
    for exercise in exercises {
        if exercise.wgerBaseId == nil, let id = wgerIdMap[exercise.name] {
            exercise.wgerBaseId = id
            patched += 1
        }
    }
    if patched > 0 {
        try? modelContext.save()
        print("Patched wger IDs for \(patched) Exercise object(s) in WorkoutPlans")
    }
}

// MARK: - Patch wger IDs for existing installs
func patchWgerIds(modelContext: ModelContext) {
    let descriptor = FetchDescriptor<ExerciseDefinition>()
    guard let definitions = try? modelContext.fetch(descriptor) else { return }

    var patched = 0
    for definition in definitions {
        if definition.wgerBaseId == nil, let id = wgerIdMap[definition.name] {
            definition.wgerBaseId = id
            patched += 1
        }
    }

    if patched > 0 {
        try? modelContext.save()
        print("Patched wger IDs for \(patched) exercise(s)")
    }
}
