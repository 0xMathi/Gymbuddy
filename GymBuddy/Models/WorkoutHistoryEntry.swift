import Foundation
import SwiftData

/// Persistierte Workout-Historie für Statistiken und Fortschrittsverfolgung
@Model
final class WorkoutHistoryEntry {
    var id: UUID = UUID()
    var planName: String
    var planId: UUID?
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var totalSets: Int
    var totalVolume: Double
    var exercisesCompleted: Int
    var createdAt: Date = Date()
    
    // JSON-encoded array of exercise snapshots for detailed review
    var exerciseSnapshots: Data?
    
    init(
        planName: String,
        planId: UUID?,
        startTime: Date,
        endTime: Date,
        duration: TimeInterval,
        totalSets: Int,
        totalVolume: Double,
        exercisesCompleted: Int,
        exerciseSnapshots: Data? = nil
    ) {
        self.planName = planName
        self.planId = planId
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.totalSets = totalSets
        self.totalVolume = totalVolume
        self.exercisesCompleted = exercisesCompleted
        self.exerciseSnapshots = exerciseSnapshots
    }
    
    // MARK: - Formatted Display
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var durationFormatted: String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var totalVolumeFormatted: String {
        guard totalVolume > 0 else { return "—" }
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: totalVolume), number: .decimal)
        return "\(formatted) KG"
    }
    
    var averageSetDuration: TimeInterval {
        guard totalSets > 0 else { return 0 }
        return duration / Double(totalSets)
    }
}

/// Snapshot einer Übung für die Historie
struct ExerciseSnapshot: Codable {
    let name: String
    let sets: Int
    let reps: Int
    let weight: Double
    let muscleGroup: String
    
    var weightFormatted: String {
        if weight == 0 {
            return "—"
        } else if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight)) KG"
        } else {
            return String(format: "%.1f KG", weight)
        }
    }
}
