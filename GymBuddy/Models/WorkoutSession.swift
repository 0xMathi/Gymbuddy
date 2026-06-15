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

    /// Total reps completed
    var totalRepsCompleted: Int {
        let sorted = sortedExercises
        var completed = 0

        for (index, exercise) in sorted.enumerated() {
            if index < currentExerciseIndex {
                completed += exercise.resolvedSets.reduce(0) { $0 + $1.reps }
            } else if index == currentExerciseIndex {
                let setsArray = exercise.resolvedSets
                let completedCount = currentSetNumber - 1
                for i in 0..<min(completedCount, setsArray.count) {
                    completed += setsArray[i].reps
                }
            }
        }

        // If completed, add the final set's reps
        if state == .completed, let exercise = currentExercise {
            let setsArray = exercise.resolvedSets
            if let lastSet = setsArray.last {
                completed += lastSet.reps
            }
        }

        return completed
    }

    /// Total volume based on sets actually completed (not the full plan)
    var totalVolume: Double {
        let sorted = sortedExercises
        var volume: Double = 0

        for (index, exercise) in sorted.enumerated() {
            let sets = exercise.resolvedSets
            let completedCount: Int
            if index < currentExerciseIndex {
                completedCount = sets.count
            } else if index == currentExerciseIndex {
                // currentSetNumber points at the upcoming set; the final set
                // only counts once the workout is completed
                completedCount = min(currentSetNumber - 1 + (state == .completed ? 1 : 0), sets.count)
            } else {
                completedCount = 0
            }

            for i in 0..<completedCount {
                volume += sets[i].weight * Double(sets[i].reps)
            }
        }

        return volume
    }

    /// Formatted in the active unit, e.g. "4.800 KG" / "10.580 LB". "—" if no weight tracked.
    var totalVolumeFormatted: String {
        guard totalVolume > 0 else { return "—" }
        let unit = AppSettings.shared.weightUnit
        let value = unit.value(fromKg: totalVolume).rounded()
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
        return "\(formatted) \(unit.labelUpper)"
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
