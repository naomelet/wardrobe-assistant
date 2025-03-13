//
// © 2025 Nao Watanabe
//

import SwiftUI
import SwiftData

@main
struct WardrobeAssistantApp: App {
//    @Environment(\.modelContext) var modelContext: ModelContext
    var body: some Scene {
        WindowGroup {
            ItemListView()
//            MinimalCategoryView()
        }
        .modelContainer(for: [Item.self, Category.self])
    }
}
