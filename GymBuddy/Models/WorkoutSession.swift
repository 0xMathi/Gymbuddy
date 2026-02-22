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
    var originalRestDuration: Int = 0 // set when rest starts, for timer bar progress

    // Time tracking
    var startTime: Date = Date()
    var endTime: Date?

    /// Duration in seconds (only valid after workout is completed)
    var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    /// Formatted duration string (MM:SS)
    var durationFormatted: String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Total sets completed
    var totalSetsCompleted: Int {
        let sortedExercises = plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
        var completed = 0

        for (index, exercise) in sortedExercises.enumerated() {
            if index < currentExerciseIndex {
                completed += exercise.sets
            } else if index == currentExerciseIndex {
                completed += currentSetNumber - 1
            }
        }

        // If completed, add the final set
        if state == .completed {
            completed += 1
        }

        return completed
    }

    /// Total exercises in the workout
    var totalExercises: Int {
        plan.exercises.count
    }

    // Helpers

    /// Exercises sorted by orderIndex — always use this instead of plan.exercises directly
    var sortedExercises: [Exercise] {
        plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
    }

    /// Progress of rest timer (1.0 = full, 0.0 = done)
    var restProgress: Double {
        guard originalRestDuration > 0 else { return 0 }
        return Double(restTimeRemaining) / Double(originalRestDuration)
    }

    var currentExercise: Exercise? {
        let sorted = sortedExercises
        guard sorted.indices.contains(currentExerciseIndex) else { return nil }
        return sorted[currentExerciseIndex]
    }

    var isLastExercise: Bool {
        currentExerciseIndex >= plan.exercises.count - 1
    }

    var isLastSet: Bool {
        guard let exercise = currentExercise else { return true }
        return currentSetNumber >= exercise.sets
    }
}
