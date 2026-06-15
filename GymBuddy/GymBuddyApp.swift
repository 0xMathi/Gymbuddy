import SwiftUI
import SwiftData
import UserNotifications

@main
struct GymBuddyApp: App {
    @State private var sessionManager = WorkoutSessionManager()
    @State private var exerciseManager = ExerciseManager()

    let modelContainer: ModelContainer

    init() {
        // First launch of the onboarding-enabled version: skip onboarding for existing
        // users (those who already have seeded data) so only fresh installs see it.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "hasCompletedOnboarding") == nil {
            let isExistingUser = defaults.bool(forKey: "hasSeededDefaultPlans")
            defaults.set(isExistingUser, forKey: "hasCompletedOnboarding")
        }

        do {
            let schema = Schema([
                WorkoutPlan.self,
                Exercise.self,
                ExerciseDefinition.self,
                CompletedWorkout.self,
                CompletedExercise.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed default exercises on first launch + patch wger IDs for existing installs
            let context = modelContainer.mainContext
            seedDefaultExercises(modelContext: context)

        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionManager)
                .environment(exerciseManager)
                .onAppear {
                    // Notification permission is requested during onboarding (with rationale).
                    exerciseManager.configure(with: modelContainer.mainContext)
                    sessionManager.configure(with: modelContainer.mainContext)
                    seedDefaultPlans(modelContext: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
