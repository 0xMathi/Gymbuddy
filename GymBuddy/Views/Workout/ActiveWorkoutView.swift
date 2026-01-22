import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var manager: WorkoutSessionManager
    
    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()
            
            if let session = manager.session, let exercise = session.currentExercise {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: Theme.Spacing.small) {
                        Text(exercise.name.uppercased())
                            .font(Theme.Fonts.h1)
                            .foregroundStyle(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("\(exercise.sets) Sets · \(exercise.restSeconds)s Rest")
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.xl)
                    
                    Spacer()
                    
                    // Main Indicator
                    VStack(spacing: Theme.Spacing.medium) {
                        Text("SET")
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .tracking(2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.small) {
                            Text("\(session.currentSetNumber)")
                                .font(Theme.Fonts.hero)
                                .foregroundStyle(Theme.Colors.textPrimary)
                            Text("/ \(exercise.sets)")
                                .font(Theme.Fonts.h2)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Controls
                    VStack(spacing: Theme.Spacing.large) {
                        PrimaryButton(title: "COMPLETE SET", icon: "checkmark") {
                            manager.completeSet()
                        }
                        
                        Button("End Workout") {
                            manager.cancelWorkout()
                        }
                        .font(Theme.Fonts.body)
                        .foregroundStyle(Theme.Colors.destructive)
                        .padding(.top, Theme.Spacing.small)
                    }
                    .padding(Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.xl) // Extra padding for safe area
                }
                
                // Rest Overlay
                if session.state == .resting {
                    RestTimerView(timeRemaining: session.restTimeRemaining) {
                        manager.skipRest()
                    }
                    .transition(.opacity)
                }
            } else {
                Text("Loading...")
            }
        }
        .animation(.easeInOut, value: manager.session?.state)
    }
}

#Preview {
    let manager = WorkoutSessionManager()
    ActiveWorkoutView(manager: manager)
}
