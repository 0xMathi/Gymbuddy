import SwiftUI
import Observation
import AVFoundation

@Observable
class WorkoutSessionManager {
    var session: WorkoutSession?
    var isActive: Bool { session != nil }

    private var timer: Timer?
    private let audio = AudioService.shared
    private let haptics = HapticService.shared

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
        
        if let exercise = plan.exercises.first {
            audio.announce("Starting \(plan.name). First up: \(exercise.name).")
        }
    }

    func completeSet() {
        guard var currentSession = session else { return }
        
        haptics.medium()
        
        guard let currentExercise = currentSession.currentExercise else { return }
        
        if currentSession.currentSetNumber < currentExercise.sets {
            // Next Set Same Exercise
            currentSession.currentSetNumber += 1
            audio.announce("Resting.")
            startRest(session: &currentSession, duration: currentExercise.restSeconds)
            
        } else if currentSession.currentExerciseIndex < currentSession.plan.exercises.count - 1 {
            // Next Exercise
            let nextExercise = currentSession.plan.exercises[currentSession.currentExerciseIndex + 1]
            currentSession.currentExerciseIndex += 1
            currentSession.currentSetNumber = 1
            
            audio.announce("Exercise Complete. Next up: \(nextExercise.name).")
            startRest(session: &currentSession, duration: currentExercise.restSeconds) 
            
        } else {
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
        
        // 10 second warning
        if currentSession.restTimeRemaining == 10 {
            haptics.warning()
            // Optional: audio.announce("Ten seconds.")
        }
        
        // 3 second countdown logic could go here
        if currentSession.restTimeRemaining == 3 {
            audio.announce("Three")
        } else if currentSession.restTimeRemaining == 2 {
            audio.announce("Two")
        } else if currentSession.restTimeRemaining == 1 {
            audio.announce("One")
        }
        
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
        
        haptics.success()
        audio.announce("Let's go!")
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
        
        haptics.success()
        audio.announce("Workout Complete. Great job!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.session = nil
        }
    }
}
