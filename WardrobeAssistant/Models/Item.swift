//
// © 2025 Nao Watanabe
//

import SwiftData
import SwiftUI

@Model
final class Item {
    var id: UUID = UUID()
    // 必須項目
    // Category
    var category: Category
    // 画像データ
    var pictureData: Data
    // timestamp
    var timestamp: Date = Date()

    // 任意項目
    // 名前
    var name: String?
    // お気に入り
    var isFavorite: Bool?
    // 購入金額
    var price: Int?

    init(         pictureData: Data,
                  category: Category,
                  name: String? = nil,
                  isFavorite: Bool? = nil,
                  price: Int? = nil) {
        self.pictureData = pictureData
        self.category = category
        self.name = name
        self.isFavorite = isFavorite
        self.price = price
    }
}
