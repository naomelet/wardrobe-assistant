//
// © 2025 Nao Watanabe
//

import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategory: Category?
    @Query(sort: \Category.displayOrder, order: .forward) private var categories: [Category]

    init(selectedCategory: Binding<Category?> = .constant(nil)) {
        _selectedCategory = selectedCategory
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Text(category.name)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("カテゴリー選択")
        }
    }
}

#Preview {
    CategoryListView()
}
