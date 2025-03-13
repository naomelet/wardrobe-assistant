//
// © 2025 Nao Watanabe
//

import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID = UUID()
    // 名前
    var name: String
    // timestamp
    var timestamp = Date()
    // 表示順
    var displayOrder: Int = 0
    // 紐づいているItem
    @Relationship(deleteRule: .cascade) var items: [Item] = []

    init(name: String,
    displayOrder: Int) {
        self.name = name
        self.displayOrder = displayOrder
    }
}
