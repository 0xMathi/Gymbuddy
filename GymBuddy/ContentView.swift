import SwiftUI

struct ContentView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if sessionManager.isActive {
                ActiveWorkoutView(manager: sessionManager)
            } else {
                StartScreenView()
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: Binding(
            get: { !hasCompletedOnboarding },
            set: { hasCompletedOnboarding = !$0 }
        )) {
            OnboardingView { hasCompletedOnboarding = true }
        }
    }
}
