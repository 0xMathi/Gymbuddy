import SwiftUI
import SwiftData

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
                ExerciseDefinition.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed default exercises on first launch
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
                    exerciseManager.configure(with: modelContainer.mainContext)
                    seedDefaultPlans(modelContext: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
