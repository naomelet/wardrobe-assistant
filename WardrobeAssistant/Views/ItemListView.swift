//
// © 2025 Nao Watanabe
//

import SwiftUI
import SwiftData

struct MinimalCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var refreshID = UUID() // 追加: View更新用

    var body: some View {
        VStack {
            List(categories) { category in
                Text(category.name)
            }

            Button("Add Category") {
                addCategory()
            }
        }
        .id(refreshID) // 追加: View更新用
    }

    private func addCategory() {
        let newCategory = Category(name: "Category \(Date())", displayOrder: categories.count + 1)
        modelContext.insert(newCategory)
        do {
            try modelContext.save()
            refreshID = UUID() // 追加: View更新トリガー
        } catch {
            print("Error saving category: \(error)")
        }
    }
}

struct ItemListView: View {
//    @EnvironmentObject var appData: AppData
    @Environment(\.modelContext) var modelContext: ModelContext
    @State private var selectedCategoryId: UUID?
    @State private var isItemRegisterPresented: Bool = false
    @State private var itemService: ItemService? = nil
    @State private var itemViewModel: ItemViewModel? = nil
    @State private var selectedItem: Item?
    @Query(sort: \Category.displayOrder, order: .forward) private var categories: [Category]

    let pageTitle: String = "アイテム一覧"

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(categories, id: \.id) { category in
                            Button(action: {
                                selectedCategoryId = category.id
                                selectedItem = nil
                            }) {
                                Text(category.name)
                                    .padding()
                                    .background(selectedCategoryId == category.id ? Color.pink : Color.gray.opacity(0.3))
                                    .foregroundColor(selectedCategoryId == category.id ? .white : .black)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.all)
                }

                Spacer()

                ZStack {
                    ScrollView {
                        // 選択されたカテゴリのアイテムを表示
                        if let selectedCategoryId = selectedCategoryId {
                            SelectedItemView(categoryId: selectedCategoryId)
                        } else {
                            Text("カテゴリを選択してください")
                                .padding()
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isItemRegisterPresented = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding(.trailing)
                    }
                }

                .fullScreenCover(isPresented: $isItemRegisterPresented) {
                    RegisterView()
                }
                .navigationTitle(pageTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Item.self) { item in
                    EditView(item: item)
                }
            }
        }.onAppear {
            if itemService == nil {
                itemService = ItemService(context: modelContext) // 初期化
                itemViewModel = ItemViewModel(itemService: itemService!) // これがないとシステムエラーになるのでアプリを落とす
            }
//            for category in categories {
//                        modelContext.delete(category)
//            }
            //TODO: categoriesはいつか登録できるようにしたい
            if categories.isEmpty {
                // 初期データを作成
                let category1 = Category(name: "インナー", displayOrder: 1)
                let category2 = Category(name: "トップス",displayOrder: 2)
                let category3 = Category(name: "アウター", displayOrder: 3)
                let category4 = Category(name: "ボトムス",  displayOrder: 4)
                let category5 = Category(name: "シューズ", displayOrder: 5)
                let category6 = Category(name: "アクセサリー", displayOrder: 6)
                let category7 = Category(name: "その他", displayOrder: 7)
                modelContext.insert(category1)
                modelContext.insert(category2)
                modelContext.insert(category3)
                modelContext.insert(category4)
                modelContext.insert(category5)
                modelContext.insert(category6)
                modelContext.insert(category7)
                do {
                            try modelContext.save()
                            print("Initial categories saved") // 保存成功のメッセージ
                        } catch {
                            print("Error saving initial categories: \(error)") // エラーメッセージ
                        }
                print(modelContext)
                print(categories)
            }
        }
    }
}

// MARK: - 選択されたアイテムを表示するView (別Viewに切り出し)
struct SelectedItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item] // @Queryをここで使う
    let categoryId: UUID
    // 3列でItemを並べる
    let columns = [
        // ()はサイズを指定している
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    init(categoryId: UUID) {
        self.categoryId = categoryId
        // predicate を使って、動的にクエリを生成する
        _items = Query(filter: #Predicate<Item> { item in
            item.category.id == categoryId
        })
    }

    var body: some View {
        if items.isEmpty {
            Text("このカテゴリにはアイテムがありません").padding()
        } else {
            LazyVGrid(columns: columns, spacing: 20) { // LazyVGrid の中に NavigationLink
                ForEach(items) { item in
                    NavigationLink(destination: EditView(item: item)) { // value ではなく destination を使う
                        VStack {
                            if let uiImage = UIImage(data: item.pictureData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
    }
//TODO: 後々実装
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ItemListView()
        .modelContainer(for: Item.self, inMemory: true)
}
