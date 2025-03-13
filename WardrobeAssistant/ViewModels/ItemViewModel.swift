//
// © 2025 Nao Watanabe
//

import SwiftData
import Foundation
import SwiftUICore

class ItemViewModel {
    @Published var items: [Item] = []
    var itemService: ItemService

    init(itemService: ItemService) {
        self.itemService = itemService
    }

    // アイテムを追加する
    func addItem(pictureData: Data,
                 category: Category,
                 name: String? = nil,
                 isFavorite: Bool? = nil,
                 price: Int? = nil) {
        let newItem = Item(pictureData: pictureData,
                           category: category,
                           name: name,
                           isFavorite: isFavorite,
                           price: price)
        itemService.addItem(item: newItem)
    }

    // アイテムを削除する
    func deleteItem(_ item: Item){
        itemService.deleteItem(item)
    }
}

