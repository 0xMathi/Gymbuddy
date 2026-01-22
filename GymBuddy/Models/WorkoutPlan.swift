import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise] = []

    init(name: String) {
        self.name = name
    }
}
