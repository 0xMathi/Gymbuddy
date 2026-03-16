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

    // wger.de image integration (copied from ExerciseDefinition)
    var wgerBaseId: Int? = nil
    var cachedImageUrl: String? = nil

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
        definitionId: UUID? = nil,
        wgerBaseId: Int? = nil,
        cachedImageUrl: String? = nil
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
        self.wgerBaseId = wgerBaseId
        self.cachedImageUrl = cachedImageUrl
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
            definitionId: definition.id,
            wgerBaseId: definition.wgerBaseId,
            cachedImageUrl: definition.cachedImageUrl
        )
    }

    // MARK: - Media

    /// Asset catalog name derived from exercise name (e.g. "exercise_bankdruecken")
    var imageName: String {
        "exercise_" + name
            .lowercased()
            .replacingOccurrences(of: "ä", with: "ae")
            .replacingOccurrences(of: "ö", with: "oe")
            .replacingOccurrences(of: "ü", with: "ue")
            .replacingOccurrences(of: "ß", with: "ss")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "&", with: "und")
    }

    /// SF Symbol fallback when no image asset is available
    var fallbackIcon: String {
        switch muscleGroup {
        case "Brust":       return "figure.strengthtraining.traditional"
        case "Rücken":      return "figure.pull.ups"
        case "Schultern":   return "figure.boxing"
        case "Bizeps":      return "figure.arms.open"
        case "Trizeps":     return "figure.arms.open"
        case "Beine":       return "figure.run"
        case "Gesäß":       return "figure.run"
        case "Core":        return "figure.core.training"
        case "Ganzkörper":  return "figure.mixed.cardio"
        case "Cardio":      return "figure.walk"
        default:            return "dumbbell.fill"
        }
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
