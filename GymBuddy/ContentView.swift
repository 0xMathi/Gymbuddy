import SwiftUI

struct ContentView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    
    var body: some View {
        Group {
            if sessionManager.isActive {
                ActiveWorkoutView(manager: sessionManager)
            } else {
                PlanListView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
