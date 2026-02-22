import Foundation
import SwiftData


@Model
final class WorkoutPlan {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date = Date()
    var orderIndex: Int = 0
    var lastUsedAt: Date? = nil

    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise] = []

    init(name: String, orderIndex: Int = 0) {
        self.name = name
        self.orderIndex = orderIndex
    }
}


