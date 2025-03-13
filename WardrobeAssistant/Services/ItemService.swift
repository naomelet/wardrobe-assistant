//
// © 2025 Nao Watanabe
//

import SwiftData
import Foundation
import SwiftUICore

class ItemService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // アイテムを追加する
    func addItem(item: Item) {
        context.insert(item)
    }

    // アイテムを削除する
    func deleteItem(_ item: Item) {
        context.delete(item)
    }
}

