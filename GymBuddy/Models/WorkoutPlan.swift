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



// MARK: - Supersets

extension WorkoutPlan {
    /// Keeps superset groups consistent after link/unlink, reorder or delete:
    /// only ADJACENT exercises may share a group, runs of length 1 lose their id,
    /// and surviving groups are relabeled A, B, C … in plan order.
    func normalizeSupersets() {
        let sorted = exercises.sorted { $0.orderIndex < $1.orderIndex }
        var label: UnicodeScalar = "A"
        var index = 0
        while index < sorted.count {
            guard let gid = sorted[index].supersetId else { index += 1; continue }
            var end = index
            while end + 1 < sorted.count, sorted[end + 1].supersetId == gid { end += 1 }
            if end == index {
                sorted[index].supersetId = nil
            } else {
                let newId = String(label)
                for i in index...end { sorted[i].supersetId = newId }
                label = UnicodeScalar(label.value + 1) ?? label
            }
            index = end + 1
        }
    }
}
