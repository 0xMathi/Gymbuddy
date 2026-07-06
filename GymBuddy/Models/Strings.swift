import Foundation

/// UI string localization (English base + German). Shares its language source with
/// ExerciseLocalization so exercise names and UI chrome always speak the same language.
///
/// Brand statement headlines (e.g. "TIME TO WORK.", "NEXT UP", "COMING UP",
/// "BEAST MODE COMPLETED") stay English in both languages by design and are not listed here.
enum L {
    private static var isGerman: Bool {
        (Bundle.main.preferredLocalizations.first ?? "en").hasPrefix("de")
    }
    private static func t(_ en: String, _ de: String) -> String { isGerman ? de : en }

    // MARK: - Start screen
    static var yourPlans: String { t("YOUR PLANS", "DEINE PLÄNE") }
    static var sort: String { t("SORT", "SORTIEREN") }
    static var done: String { t("DONE", "FERTIG") }
    static var noPlansYet: String { t("NO PLANS YET", "NOCH KEINE PLÄNE") }
    static var createFirstPlan: String { t("Create your first workout plan", "Erstelle deinen ersten Trainingsplan") }
    static var createPlan: String { t("CREATE PLAN", "PLAN ERSTELLEN") }
    static var newPlanName: String { t("New Plan", "Neuer Plan") }
    static var musclesPush: String { t("Chest · Shoulders · Triceps", "Brust · Schultern · Trizeps") }
    static var musclesPull: String { t("Back · Biceps · Rear Delts", "Rücken · Bizeps · Hintere Schulter") }
    static var musclesLegs: String { t("Quads · Hamstrings · Glutes", "Quads · Beinbizeps · Gesäß") }
    static func exercisesCount(_ n: Int) -> String { t("\(n) exercises", "\(n) Übungen") }
    static var lastUsedToday: String { t("LAST · TODAY", "ZULETZT · HEUTE") }
    static var lastUsedYesterday: String { t("LAST · YESTERDAY", "ZULETZT · GESTERN") }
    static func lastUsedDaysAgo(_ d: Int) -> String { t("LAST · \(d) DAYS AGO", "ZULETZT · VOR \(d) TAGEN") }
    static func lastUsedOn(_ date: String) -> String { t("LAST · \(date)", "ZULETZT · \(date)") }

    // MARK: - Onboarding
    static var onbSub: String { t("A fast, focused workout tracker. No subscriptions, no noise — just you and the iron.",
                                  "Ein schneller, fokussierter Workout-Tracker. Kein Abo, kein Lärm — nur du und das Eisen.") }
    static var onbGetStarted: String { t("Get started", "Los geht's") }
    static var onbUnitTitle: String { t("Your unit.", "Deine Einheit.") }
    static var onbUnitQuestion: String { t("Which unit do you train in?", "In welcher Einheit trainierst du?") }
    static var unitKilograms: String { t("Kilograms", "Kilogramm") }
    static var unitPounds: String { t("Pounds", "Pfund") }
    static var onbUnitChangeable: String { t("Change it anytime in Settings.", "Jederzeit in den Einstellungen änderbar.") }
    static var onbContinue: String { t("Continue", "Weiter") }
    static var onbReadyTitle: String { t("You're set.", "Bereit.") }
    static var onbReadyBody: String { t("Push, Pull & Leg Day are ready to go — tweak them or build your own. Tap a plan, and go.",
                                        "Push, Pull & Leg Day sind schon eingerichtet — pass sie an oder bau eigene. Tipp einen Plan, und los.") }
    static var onbNotifPrime: String { t("The rest timer buzzes you — even from your pocket.",
                                         "Der Pause-Timer piept dich an — auch aus der Tasche.") }
    static var onbAllowNotifs: String { t("Allow notifications", "Mitteilungen erlauben") }
    static var onbMaybeLater: String { t("Maybe later", "Vielleicht später") }

    // MARK: - Settings
    static var settings: String { t("Settings", "Einstellungen") }
    static var appearance: String { t("Appearance", "Darstellung") }
    static var appearanceUpper: String { t("APPEARANCE", "DARSTELLUNG") }
    static var workoutDefaultsUpper: String { t("WORKOUT DEFAULTS", "WORKOUT-STANDARDS") }
    static var unit: String { t("Unit", "Einheit") }
    static var unitKgLong: String { t("Kilograms (kg)", "Kilogramm (kg)") }
    static var unitLbLong: String { t("Pounds (lb)", "Pfund (lb)") }
    static var defaultRest: String { t("Default Rest", "Standard-Pause") }
    static var appearanceSystem: String { t("System", "System") }
    static var appearanceLight: String { t("Light", "Hell") }
    static var appearanceDark: String { t("Dark", "Dunkel") }

    // MARK: - Active workout
    static var endWorkoutQuestion: String { t("End workout?", "Workout beenden?") }
    static var end: String { t("End", "Beenden") }
    static var endAndSave: String { t("Finish & save", "Beenden & speichern") }
    static var discardWorkout: String { t("Discard workout", "Workout verwerfen") }
    static var endWorkoutMessageSave: String { t("Save your completed sets, or discard the workout.", "Speichere deine erledigten Sätze — oder verwirf das Workout.") }
    static var cancel: String { t("Cancel", "Abbrechen") }
    static var progressLost: String { t("Your progress will be lost.", "Dein Fortschritt geht verloren.") }
    static var supersetNoRest: String { t("SUPERSET · NO REST", "SUPERSET · KEINE PAUSE") }
    static var endWorkoutUpper: String { t("END WORKOUT", "WORKOUT BEENDEN") }
    static var endUpper: String { t("END", "ENDE") }
    static func exerciseProgress(_ i: Int, _ n: Int) -> String { t("EXERCISE \(i) / \(n)", "ÜBUNG \(i) / \(n)") }
    static func setsRestMeta(_ sets: Int, _ rest: String) -> String { t("\(sets) SETS · REST \(rest)", "\(sets) SÄTZE · PAUSE \(rest)") }
    static func setN(_ n: Int) -> String { t("SET \(n)", "SATZ \(n)") }
    static func lastTime(_ weight: String, _ reps: Int) -> String { t("LAST TIME · \(weight) × \(reps)", "LETZTES MAL · \(weight) × \(reps)") }
    static var addSet: String { t("Add set", "Satz hinzufügen") }
    static var restartExerciseUpper: String { t("RESTART EXERCISE", "ÜBUNG NEU STARTEN") }
    static var continueHereUpper: String { t("CONTINUE HERE", "HIER WEITERMACHEN") }
    static func backToExercise(_ i: Int) -> String { t("BACK TO EXERCISE \(i)", "ZURÜCK ZU ÜBUNG \(i)") }
    static func restSetN(_ n: Int) -> String { t("REST · SET \(n)", "PAUSE · SATZ \(n)") }
    static var rest: String { t("REST", "PAUSE") }
    static var finishUpper: String { t("FINISH", "FERTIG") }
    static var lastSetUpper: String { t("LAST SET", "LETZTER SATZ") }
    static func then(_ name: String) -> String { t("THEN: \(name)", "DANN: \(name)") }
    static var restRunning: String { t("REST RUNNING", "PAUSE LÄUFT") }
    static var delete: String { t("Delete", "Löschen") }
    static var edit: String { t("Edit", "Bearbeiten") }
    static func previewExercise(_ i: Int, _ n: Int) -> String { t("PREVIEW · EXERCISE \(i) / \(n)", "VORSCHAU · ÜBUNG \(i) / \(n)") }
    static var previewDone: String { t("PREVIEW · DONE ✓", "VORSCHAU · ERLEDIGT ✓") }
    static var skip: String { t("SKIP", "ÜBERSPRINGEN") }
    static func setsRepsMeta(_ sets: Int, _ reps: Int) -> String { t("\(sets) SETS × \(reps) REPS", "\(sets) SÄTZE × \(reps) WDH") }
    static var paused: String { t("PAUSED", "PAUSIERT") }
    static var tapToResume: String { t("TAP TO RESUME", "TIPPEN ZUM FORTSETZEN") }
    static var loading: String { t("LOADING …", "LADE …") }
    static var setsUpper: String { t("SETS", "SÄTZE") }
    static var repsUpper: String { t("REPS", "WDH") }
    static var weightUpper: String { t("WEIGHT", "GEWICHT") }
    static var restUpper: String { t("REST", "PAUSE") }
    static var jumpToExerciseUpper: String { t("JUMP TO EXERCISE", "ZU DIESER ÜBUNG") }
    static var markAsDoneUpper: String { t("MARK AS DONE", "ALS ERLEDIGT MARKIEREN") }
    static func editSetN(_ n: Int) -> String { t("EDIT SET \(n)", "\(n). SATZ BEARBEITEN") }
    static var save: String { t("Save", "Speichern") }
    static var cancelUpper: String { t("CANCEL", "ABBRECHEN") }
    static var saveUpper: String { t("SAVE", "SPEICHERN") }

    // MARK: - Summary
    static func completedOn(_ date: String) -> String { t("completed on \(date)", "abgeschlossen am \(date)") }
    static var duration: String { t("Duration", "Trainingsdauer") }
    static var volume: String { t("Volume", "Bewegtes Gewicht") }
    static var exercises: String { t("Exercises", "Übungen") }
    static var setsLabel: String { t("Sets", "Sätze") }
    static var repsLabel: String { t("Reps", "Wiederholungen") }
    static var lastSession: String { t("Last session", "Letzte Session") }
    static var finishWorkout: String { t("Finish workout", "Training abschließen") }

    // MARK: - Plan editor
    static var editPlanUpper: String { t("EDIT PLAN", "PLAN BEARBEITEN") }
    static var planNameUpper: String { t("PLAN NAME", "PLAN-NAME") }
    static var myWorkoutPlaceholder: String { t("MY WORKOUT", "MEIN WORKOUT") }
    static var noExercisesYet: String { t("NO EXERCISES YET", "NOCH KEINE ÜBUNGEN") }
    static var addExercisesToBuild: String { t("Add exercises to build your plan.", "Füge Übungen hinzu, um deinen Plan aufzubauen.") }
    static var addExercisesUpper: String { t("ADD EXERCISES", "ÜBUNGEN HINZUFÜGEN") }
    static func setsCount(_ n: Int) -> String { t("\(n) sets", "\(n) Sätze") }
    static func repsCount(_ n: Int) -> String { t("\(n) reps", "\(n) Wdh") }
    static var keyboard: String { t("KEYBOARD", "TASTATUR") }
    static var picker: String { t("PICKER", "PICKER") }
    static var individualSetsUpper: String { t("INDIVIDUAL SETS", "EINZELNE SÄTZE") }
    static func setRowN(_ i: Int) -> String { t("Set \(i)", "\(i). Satz") }
    static var addSetUpper: String { t("ADD SET", "SATZ HINZUFÜGEN") }
    static var exerciseDetailsUpper: String { t("EXERCISE DETAILS", "ÜBUNGS-DETAILS") }

    // MARK: - Tip Jar
    static var supportGymBuddy: String { t("Support GymBuddy", "GymBuddy unterstützen") }
    static var tipTitle: String { t("Support GymBuddy", "GymBuddy unterstützen") }
    static var tipIntro: String { t("GymBuddy is free — no ads, no account. If it earned a spot in your gym bag, you can leave a tip. Completely optional, hugely appreciated.",
                                    "GymBuddy ist gratis — keine Werbung, kein Account. Wenn die App einen Platz in deiner Gym-Bag verdient hat, kannst du was dalassen. Komplett freiwillig, riesig wertgeschätzt.") }
    static var tipSubSmall: String { t("Spot me a set.", "Gib mir 'nen Satz aus.") }
    static var tipSubMedium: String { t("Fuel the gains.", "Treibstoff für die Gains.") }
    static var tipSubLarge: String { t("Absolute legend.", "Absolute Legende.") }
    static var tipUnavailable: String { t("Tips aren't available right now.", "Tips sind gerade nicht verfügbar.") }
    static var tipNoUnlock: String { t("Nothing gets unlocked — it's pure goodwill.", "Es wird nichts freigeschaltet — reine Wertschätzung.") }
    static var tipThanksTitle: String { t("Thank you. Seriously.", "Danke. Wirklich.") }
    static var tipThanksBody: String { t("That means a lot. Now go hit a PR.", "Das bedeutet mir viel. Jetzt geh und reiß 'nen PR.") }
    static var tipClose: String { t("You're welcome", "Gern geschehen") }

    // MARK: - Notifications
    static var notifRestOverTitle: String { t("Rest's over!", "Pause vorbei!") }
    static var notifRestOverBody: String { t("Get ready for your next set.", "Mach dich bereit für den nächsten Satz.") }

    // MARK: - Exercise picker
    static var all: String { t("All", "Alle") }
    static var favorites: String { t("Favorites", "Favoriten") }
    static var addExercisesTitle: String { t("Add Exercises", "Übungen hinzufügen") }
    static var searchExercises: String { t("Search exercises …", "Übung suchen …") }
    static func addCount(_ n: Int) -> String { t("Add (\(n))", "Hinzufügen (\(n))") }
}
