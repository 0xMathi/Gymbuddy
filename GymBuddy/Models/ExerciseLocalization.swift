import Foundation

/// Localized DISPLAY names for exercises & muscle groups.
/// The stored `name` (German canonical) stays the internal key — it drives image asset
/// lookup and "Letztes Mal" history. Only the on-screen text is localized here.
enum ExerciseLocalization {

    /// Follows the resolved UI language so exercise names match the rest of the app
    /// ("de" → German canonical; everything else → English).
    private static var isGerman: Bool {
        (Bundle.main.preferredLocalizations.first ?? "en").hasPrefix("de")
    }

    // MARK: - Exercises (German key → English display)

    private static let exercisesEN: [String: String] = [
        // Chest
        "Bankdrücken": "Bench Press",
        "Schrägbankdrücken": "Incline Bench Press",
        "Kurzhantel-Bankdrücken": "Dumbbell Bench Press",
        "KH-Bankdrücken": "Dumbbell Bench Press",
        "KH-Bankdrücken flach": "Flat Dumbbell Press",
        "Kurzhantel-Flys": "Dumbbell Flyes",
        "Cable-Crossover": "Cable Crossover",
        "Liegestütze": "Push-Ups",
        "Dips (Brust)": "Chest Dips",
        "Dips": "Dips",
        "Butterfly-Maschine": "Pec Deck",
        // Back
        "Kreuzheben": "Deadlift",
        "KH-Kreuzheben oder RDL": "Dumbbell Deadlift / RDL",
        "Klimmzüge": "Pull-Ups",
        "Langhantel-Rudern": "Barbell Row",
        "Langhantel-Rudern stehend": "Bent-Over Barbell Row",
        "Kurzhantel-Rudern": "Dumbbell Row",
        "Einarmiges KH-Rudern": "One-Arm Dumbbell Row",
        "Latzug": "Lat Pulldown",
        "Kabelrudern": "Seated Cable Row",
        "T-Bar Rudern": "T-Bar Row",
        "T-Bar Rudern / KH-Rudern": "T-Bar Row / DB Row",
        "Face Pulls": "Face Pulls",
        // Shoulders
        "Schulterdrücken": "Overhead Press",
        "Kurzhantel-Schulterdrücken": "Dumbbell Shoulder Press",
        "Schulterdrücken KH": "Dumbbell Shoulder Press",
        "Seitheben": "Lateral Raises",
        "Kabelzug-Seitenheben": "Cable Lateral Raise",
        "Frontheben": "Front Raises",
        "Arnold Press": "Arnold Press",
        "Aufrechtes Rudern": "Upright Row",
        "Reverse Flys": "Reverse Flyes",
        // Biceps
        "Langhantel-Curls": "Barbell Curl",
        "Kurzhantel-Curls": "Dumbbell Curl",
        "Bizeps-Curls KH": "Dumbbell Biceps Curl",
        "Hammer Curls": "Hammer Curls",
        "Preacher Curls": "Preacher Curls",
        "Kabelzug-Curls": "Cable Curls",
        "Kabel-Bizeps-Curls": "Cable Biceps Curl",
        "Konzentrations-Curls": "Concentration Curls",
        // Triceps
        "Trizeps-Dips": "Triceps Dips",
        "Trizepsdrücken am Kabel": "Triceps Pushdown",
        "Trizeps-Drücken Seil": "Rope Triceps Pushdown",
        "Kabel-Overhead-Trizeps": "Overhead Cable Triceps Ext.",
        "Skull Crushers": "Skull Crushers",
        "Overhead Trizeps Extension": "Overhead Triceps Extension",
        "Enges Bankdrücken": "Close-Grip Bench Press",
        "Kickbacks": "Triceps Kickbacks",
        // Legs
        "Kniebeugen": "Squats",
        "Kniebeuge Langhantel": "Barbell Squat",
        "Frontkniebeugen": "Front Squats",
        "Beinpresse": "Leg Press",
        "Ausfallschritte": "Lunges",
        "Ausfallschritte KH": "Dumbbell Lunges",
        "Bulgarische Split Squats": "Bulgarian Split Squats",
        "Beinstrecker": "Leg Extension",
        "Beinbeuger": "Leg Curl",
        "Wadenheben stehend": "Standing Calf Raise",
        "Wadenheben sitzend": "Seated Calf Raise",
        "Rumänisches Kreuzheben": "Romanian Deadlift",
        // Glutes
        "Hip Thrusts": "Hip Thrusts",
        "Glute Bridge": "Glute Bridge",
        "Cable Pull-Through": "Cable Pull-Through",
        "Sumo Kreuzheben": "Sumo Deadlift",
        // Core
        "Planke": "Plank",
        "Crunches": "Crunches",
        "Beinheben hängend": "Hanging Leg Raises",
        "Hanging Leg Raises": "Hanging Leg Raises",
        "Russian Twists": "Russian Twists",
        "Ab-Rollout": "Ab Rollout",
        "Kabelzug-Crunches": "Cable Crunches",
        // Full body
        "Thrusters": "Thrusters",
        "Clean & Press": "Clean & Press",
        "Kettlebell Swings": "Kettlebell Swings",
        "Burpees": "Burpees",
        "Turkish Get-Up": "Turkish Get-Up",
    ]

    // MARK: - Muscle groups (German key → English display)

    private static let muscleGroupsEN: [String: String] = [
        "Brust": "Chest",
        "Rücken": "Back",
        "Schultern": "Shoulders",
        "Bizeps": "Biceps",
        "Trizeps": "Triceps",
        "Beine": "Legs",
        "Gesäß": "Glutes",
        "Core": "Core",
        "Ganzkörper": "Full Body",
        "Cardio": "Cardio",
        "Sonstiges": "Other",
    ]

    // MARK: - Lookup

    /// Localized exercise name. Falls back to the original (e.g. custom user exercises).
    static func exercise(_ name: String) -> String {
        isGerman ? name : (exercisesEN[name] ?? name)
    }

    /// Localized muscle group. Falls back to the original.
    static func muscleGroup(_ name: String) -> String {
        isGerman ? name : (muscleGroupsEN[name] ?? name)
    }
}
