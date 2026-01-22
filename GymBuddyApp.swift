import SwiftUI
import SwiftData

@main
struct GymBuddyApp: App {
    @State private var sessionManager = WorkoutSessionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionManager)
        }
        .modelContainer(for: [WorkoutPlan.self, Exercise.self])
    }
}
