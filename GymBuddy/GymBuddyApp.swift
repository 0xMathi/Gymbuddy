import SwiftUI
import SwiftData
import UserNotifications

@main
struct GymBuddyApp: App {
    @State private var sessionManager = WorkoutSessionManager()
    @State private var exerciseManager = ExerciseManager()

    let modelContainer: ModelContainer

    init() {
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
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                    exerciseManager.configure(with: modelContainer.mainContext)
                    sessionManager.configure(with: modelContainer.mainContext)
                    seedDefaultPlans(modelContext: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
