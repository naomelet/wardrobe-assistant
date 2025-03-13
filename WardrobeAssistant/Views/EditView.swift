//
// © 2025 Nao Watanabe
//

import SwiftUI
import SwiftData

struct EditView: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var item: Item
    @State private var itemService: ItemService? = nil
    @State private var itemViewModel: ItemViewModel? = nil
    // 画像関連
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var isCameraPresented: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var isDeleteAlertPresented = false
    @State private var isActionSheetPresented: Bool = false

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.zeroSymbol = ""
        return formatter
    }()

    var body: some View {
        NavigationStack {
            Form {
                // 必須項目
                Section(header: Text("基本情報（必須）").font(.title3)) {
                    // 画像
                    if let selectedImage = selectedImage { // 新規に選択した画像がある場合
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    } else if let uiImage = UIImage(data: item.pictureData) { // 既存の画像データがある場合
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                isActionSheetPresented = true
                            }
                    } else { // 画像データがない場合（通常起こらないはず）
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 200)
                            .overlay(
                                Text("ここをタップして写真を登録してください")
                                    .foregroundStyle(.white)
                            )
                            .onTapGesture {
                                isActionSheetPresented = true
                            }
                    }
                    // カテゴリー
                    NavigationLink(destination: CategoryListView(selectedCategory: Binding(
                        get: { item.category }, // Category を返す
                        set: { item.category = $0 ?? item.category} // Category? を受け取り、nil でない場合は item.category に設定
                    ))) {
                        Text(item.category.name)                                    }
                }

                // 任意項目
                Section(header: Text("詳細情報").font(.title3)) {
                    //名前
                    TextField("名前", text: $item.name.nilCoalescing(with: ""))
                    // お気に入り
                    Toggle("お気に入り", isOn: $item.isFavorite.nilCoalescing(with: false))
                    // 購入金額
                    TextField("購入金額", value: $item.price, formatter: formatter)
                        .keyboardType(.numberPad)
                }
            }
            .navigationBarTitle("アイテム編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isDeleteAlertPresented = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.primary)
                    }
                }

            }
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(title: Text("写真はどちらの方法で登録しますか？"),
                            buttons: [
                                .default(Text("ライブラリから選択")) {
                                    sourceType = .photoLibrary
                                    isImagePickerPresented = true
                                },
                                .default(Text("写真を撮る")) {
                                    sourceType = .camera
                                    isImagePickerPresented = true
                                },
                                .cancel(Text("キャンセル"))
                            ])
            }
            .sheet(isPresented: $isActionSheetPresented) {
                ImagePicker(sourceType: sourceType,
                            selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { oldImage, newImage in
                if let newImage = newImage,
                   let newImageData = newImage.pngData() {
                    item.pictureData = newImageData
                }
            }
            .alert(isPresented: $isDeleteAlertPresented) {
                Alert(title: Text("本当に削除しますか？"),
                      primaryButton: .destructive(Text("削除"), action: deleteItem),
                      secondaryButton: .cancel())
            }

        }
        .onAppear {
            if itemService == nil {
                itemService = ItemService(context: modelContext) // 初期化
                itemViewModel = ItemViewModel(itemService: itemService!) // これがないとシステムエラーになるのでアプリを落とす
            }
        }
    }

    private func deleteItem() {
        itemViewModel?.deleteItem(item)
        dismiss()
    }
}

// nilCoalescing(with:) を使うための Binding の拡張
extension Binding {
    func nilCoalescing<T>(with fallback: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? fallback },
            set: { newValue in
                self.wrappedValue = newValue
            }
        )
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditView(item: Item(pictureData: Data(), category: Category(name: "Category", displayOrder: 1), name: "テスト1", isFavorite: true))
        }
    }
}
