import Foundation
import SwiftData

@Model
final class ExerciseDefinition {
    var id: UUID = UUID()
    var name: String
    var muscleGroup: String
    var equipment: String
    var isCustom: Bool = false
    var isFavorite: Bool = false
    var createdAt: Date = Date()

    // wger.de integration (free exercise image API)
    var wgerBaseId: Int? = nil
    var cachedImageUrl: String? = nil

    init(name: String, muscleGroup: String, equipment: String, isCustom: Bool = false) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.isCustom = isCustom
    }
}

// MARK: - Media
extension ExerciseDefinition {
    /// Asset catalog name derived from the exercise name (e.g. "exercise_bankdruecken")
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
        case MuscleGroup.chest.rawValue:    return "figure.strengthtraining.traditional"
        case MuscleGroup.back.rawValue:     return "figure.pull.ups"
        case MuscleGroup.shoulders.rawValue: return "figure.boxing"
        case MuscleGroup.biceps.rawValue:   return "figure.arms.open"
        case MuscleGroup.triceps.rawValue:  return "figure.arms.open"
        case MuscleGroup.legs.rawValue:     return "figure.run"
        case MuscleGroup.glutes.rawValue:   return "figure.run"
        case MuscleGroup.core.rawValue:     return "figure.core.training"
        case MuscleGroup.fullBody.rawValue: return "figure.mixed.cardio"
        case MuscleGroup.cardio.rawValue:   return "figure.walk"
        default:                            return "dumbbell.fill"
        }
    }
}

// MARK: - Muscle Groups
extension ExerciseDefinition {
    enum MuscleGroup: String, CaseIterable {
        case chest = "Brust"
        case back = "Rücken"
        case shoulders = "Schultern"
        case biceps = "Bizeps"
        case triceps = "Trizeps"
        case legs = "Beine"
        case glutes = "Gesäß"
        case core = "Core"
        case fullBody = "Ganzkörper"
        case cardio = "Cardio"
    }

    enum Equipment: String, CaseIterable {
        case barbell = "Langhantel"
        case dumbbell = "Kurzhantel"
        case machine = "Maschine"
        case cable = "Kabelzug"
        case bodyweight = "Körpergewicht"
        case kettlebell = "Kettlebell"
        case bands = "Widerstandsbänder"
        case other = "Sonstiges"
    }
}
