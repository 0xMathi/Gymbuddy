import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID = UUID()
    var name: String
    var sets: Int
    var restSeconds: Int
    var orderIndex: Int
    
    @Relationship(inverse: \WorkoutPlan.exercises) 
    var plan: WorkoutPlan?

    init(name: String, sets: Int, restSeconds: Int, orderIndex: Int) {
        self.name = name
        self.sets = sets
        self.restSeconds = restSeconds
        self.orderIndex = orderIndex
    }
}
