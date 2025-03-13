//
// © 2025 Nao Watanabe
//

import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var itemService: ItemService? = nil
    @State private var itemViewModel: ItemViewModel? = nil
    // 入力項目
    @State private var name: String = ""
    @State private var price: Int = 0
    @State private var isFavorite: Bool = false
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.zeroSymbol = ""
        return formatter
    }()
    @State private var selectedCategory: Category? = nil
    // 画像関連
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var isCameraPresented: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var isActionSheetPresented: Bool = false
    @State private var isErrorAlertPresented = false
    @State private var errorMessage: String? = nil

    @Query(sort: \Category.displayOrder, order: .forward) private var categories: [Category]

    var body: some View {
        NavigationStack {
            Form {
                // 必須項目
                Section(header: Text("基本情報（必須）").font(.title3)) {
                    // 画像
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    } else {
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
                    NavigationLink(destination: CategoryListView(selectedCategory: $selectedCategory)) {
                        if let categoryName = selectedCategory?.name {
                                                Text(categoryName)
                        } else {
                            TextField("カテゴリー", text: .constant("")).disabled(true)

                        }
                                    }
                }

                // 任意項目
                Section(header: Text("詳細情報").font(.title3)) {
                    // 名前
                    TextField("名前", text: $name)
                    // お気に入り
                    Toggle("お気に入り", isOn: $isFavorite)
                    // 金額
                    TextField("購入金額", value: $price, formatter: formatter)
                        .keyboardType(.numberPad)
                }

                Button(action: {
                    saveItem(
                        selectedImage: selectedImage!,
                        category: selectedCategory!,
                        name: name,
                        isFavorite: isFavorite,
                        price: price) // 絶対nilにならない
                    dismiss()
                }) {
                    Text("登録")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(selectedCategory == nil || selectedImage == nil)
            }
            .navigationBarTitle("アイテム登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // Modalなので、dismissする
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
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
        }
        .onAppear {
            if itemService == nil {
                itemService = ItemService(context: modelContext) // 初期化
                itemViewModel = ItemViewModel(itemService: itemService!) // これがないとシステムエラーになるのでアプリを落とす
            }
        }
    }

    // アイテムを保存する
    private func saveItem(selectedImage: UIImage,
                          category: Category,
                          name: String?,
                          isFavorite: Bool?,
                          price: Int?
    ) {
        guard let pictureData = selectedImage.pngData() else {
            errorMessage = "画像の変換に失敗しました"
            isErrorAlertPresented = true
            return
        }
        itemViewModel?.addItem(pictureData: pictureData,
                               category: category,
                               name: name,
                               isFavorite: isFavorite,
                               price: price)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisterView()
        }
    }
}
