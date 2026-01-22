import Foundation
import SwiftData

struct WorkoutSession {
    enum State: Equatable {
        case active
        case resting
        case paused
        case completed
    }

    let plan: WorkoutPlan
    var state: State = .active
    
    var currentExerciseIndex: Int = 0
    var currentSetNumber: Int = 1 // 1-based
    var restTimeRemaining: Int = 0
    
    // Helpers
    var currentExercise: Exercise? {
        guard plan.exercises.indices.contains(currentExerciseIndex) else { return nil }
        return plan.exercises[currentExerciseIndex]
    }
    
    var isLastExercise: Bool {
        currentExerciseIndex >= plan.exercises.count - 1
    }
    
    var isLastSet: Bool {
        guard let exercise = currentExercise else { return true }
        return currentSetNumber >= exercise.sets
    }
}
