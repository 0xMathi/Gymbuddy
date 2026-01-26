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

    init(name: String, muscleGroup: String, equipment: String, isCustom: Bool = false) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.isCustom = isCustom
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
