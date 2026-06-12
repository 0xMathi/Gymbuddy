import Foundation
import SwiftData

/// One persisted set result (reps × weight) inside a completed exercise
struct CompletedSetData: Codable, Equatable {
    var reps: Int
    var weight: Double
}

/// Persisted record of a finished workout session — source for "Letztes Mal" values
@Model
final class CompletedWorkout {
    var planName: String
    var startTime: Date
    var endTime: Date
    var totalVolume: Double

    @Relationship(deleteRule: .cascade, inverse: \CompletedExercise.workout)
    var exercises: [CompletedExercise] = []

    init(planName: String, startTime: Date, endTime: Date, totalVolume: Double) {
        self.planName = planName
        self.startTime = startTime
        self.endTime = endTime
        self.totalVolume = totalVolume
    }

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}

@Model
final class CompletedExercise {
    /// Lookup key for "Letztes Mal" — renaming an exercise intentionally resets its history
    var name: String
    var orderIndex: Int
    /// Only sets that were actually completed
    var sets: [CompletedSetData]

    var workout: CompletedWorkout?

    init(name: String, orderIndex: Int, sets: [CompletedSetData]) {
        self.name = name
        self.orderIndex = orderIndex
        self.sets = sets
    }
}
