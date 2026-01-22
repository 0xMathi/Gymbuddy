import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID = UUID()

    // Copy-on-Write: Copied from ExerciseDefinition
    var name: String
    var muscleGroup: String
    var equipment: String

    // Plan-specific settings
    var sets: Int
    var reps: Int
    var weight: Double  // in kg
    var restSeconds: Int
    var orderIndex: Int

    // Optional reference to original definition (for updates)
    var definitionId: UUID?

    @Relationship(inverse: \WorkoutPlan.exercises)
    var plan: WorkoutPlan?

    init(
        name: String,
        sets: Int,
        reps: Int = 10,
        weight: Double = 0,
        restSeconds: Int,
        orderIndex: Int,
        muscleGroup: String = "",
        equipment: String = "",
        definitionId: UUID? = nil
    ) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.restSeconds = restSeconds
        self.orderIndex = orderIndex
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.definitionId = definitionId
    }

    /// Create Exercise from ExerciseDefinition (Copy-on-Write)
    convenience init(
        from definition: ExerciseDefinition,
        sets: Int = 3,
        reps: Int = 10,
        weight: Double = 0,
        restSeconds: Int = 90,
        orderIndex: Int = 0
    ) {
        self.init(
            name: definition.name,
            sets: sets,
            reps: reps,
            weight: weight,
            restSeconds: restSeconds,
            orderIndex: orderIndex,
            muscleGroup: definition.muscleGroup,
            equipment: definition.equipment,
            definitionId: definition.id
        )
    }

    // MARK: - Formatted Display

    var weightFormatted: String {
        if weight == 0 {
            return "—"
        } else if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight)) KG"
        } else {
            return String(format: "%.1f KG", weight)
        }
    }

    var repsFormatted: String {
        "\(reps) REPS"
    }

    var summaryText: String {
        "\(sets) × \(reps) @ \(weightFormatted)"
    }
}
