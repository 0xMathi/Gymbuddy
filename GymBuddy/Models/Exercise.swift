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
    var restSeconds: Int
    var orderIndex: Int

    // Optional reference to original definition (for updates)
    var definitionId: UUID?

    @Relationship(inverse: \WorkoutPlan.exercises)
    var plan: WorkoutPlan?

    init(name: String, sets: Int, restSeconds: Int, orderIndex: Int, muscleGroup: String = "", equipment: String = "", definitionId: UUID? = nil) {
        self.name = name
        self.sets = sets
        self.restSeconds = restSeconds
        self.orderIndex = orderIndex
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.definitionId = definitionId
    }

    /// Create Exercise from ExerciseDefinition (Copy-on-Write)
    convenience init(from definition: ExerciseDefinition, sets: Int = 3, restSeconds: Int = 90, orderIndex: Int = 0) {
        self.init(
            name: definition.name,
            sets: sets,
            restSeconds: restSeconds,
            orderIndex: orderIndex,
            muscleGroup: definition.muscleGroup,
            equipment: definition.equipment,
            definitionId: definition.id
        )
    }
}
