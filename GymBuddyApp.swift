import SwiftUI
import SwiftData

@main
struct GymBuddyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WorkoutPlan.self, Exercise.self])
    }
}
