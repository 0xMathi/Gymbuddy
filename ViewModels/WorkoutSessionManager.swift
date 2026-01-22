import SwiftUI
import Observation
import AVFoundation

@Observable
class WorkoutSessionManager {
    var session: WorkoutSession?
    var isActive: Bool { session != nil }

    private var timer: Timer?

    // MARK: - Core Actions

    func startWorkout(plan: WorkoutPlan) {
        guard !plan.exercises.isEmpty else { return }
        
        session = WorkoutSession(
            plan: plan,
            state: .active,
            currentExerciseIndex: 0,
            currentSetNumber: 1,
            restTimeRemaining: 0
        )
    }

    func completeSet() {
        guard var currentSession = session else { return }
        
        // Haptic Feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        guard let currentExercise = currentSession.currentExercise else { return }
        
        // Logic: Determine Next State
        if currentSession.currentSetNumber < currentExercise.sets {
            // Next Set Same Exercise
            currentSession.currentSetNumber += 1 // Increment to prepare for next set
            startRest(session: &currentSession, duration: currentExercise.restSeconds)
            
        } else if currentSession.currentExerciseIndex < currentSession.plan.exercises.count - 1 {
            // Next Exercise
            currentSession.currentExerciseIndex += 1
            currentSession.currentSetNumber = 1
            
            // Allow rest between exercises? Usually yes.
            // Using same rest timer for now.
            startRest(session: &currentSession, duration: currentExercise.restSeconds) 
            
        } else {
            // Workout Complete
            finishWorkout()
            return
        }
        
        self.session = currentSession
    }

    func skipRest() {
        endRest()
    }
    
    func cancelWorkout() {
        stopTimer()
        session = nil
    }

    // MARK: - Internal Logic

    private func startRest(session: inout WorkoutSession, duration: Int) {
        session.state = .resting
        session.restTimeRemaining = duration
        
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard var currentSession = session, currentSession.state == .resting else { return }
        
        currentSession.restTimeRemaining -= 1
        
        if currentSession.restTimeRemaining <= 0 {
            endRest()
        } else {
            session = currentSession
        }
    }
    
    private func endRest() {
        stopTimer()
        guard var currentSession = session else { return }
        
        currentSession.state = .active
        session = currentSession
        
        // Success Haptic
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func finishWorkout() {
        stopTimer()
        guard var currentSession = session else { return }
        currentSession.state = .completed
        session = currentSession
        
        // Haptic
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // Auto-close after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.session = nil
        }
    }
}
