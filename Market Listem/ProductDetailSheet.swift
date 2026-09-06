import SwiftUI
import SwiftData

struct ProductDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ProductArchiveStore.self) private var archiveStore
    let product: Product
    @State private var category: ProductCategory
    @State private var quantity: Int
    @State private var isConfirmingArchive = false

    init(product: Product) {
        self.product = product
        _category = State(initialValue: product.category)
        _quantity = State(initialValue: product.quantity)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        ProductThumbnail(name: product.name, category: category, size: 76)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Ürün") {
                    LabeledContent("Ad", value: product.name)
                    Picker("Kategori", selection: $category) {
                        ForEach(ProductCategory.allCases) { category in
                            Label(category.title, systemImage: category.symbol).tag(category)
                        }
                    }
                }

                Section("Adet") {
                    Stepper(value: $quantity, in: 1...99) {
                        LabeledContent("Miktar", value: "\(quantity)")
                    }
                }

                Section {
                    Button("Takipten Çıkar", systemImage: "archivebox") {
                        isConfirmingArchive = true
                    }
                    .foregroundStyle(.orange)
                } footer: {
                    Text("Ürün arşivlenir; satın alma geçmişi korunur ve istediğin zaman geri yükleyebilirsin.")
                }
            }
            .navigationTitle("Ürün Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Vazgeç") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        InventoryService.update(product, category: category, quantity: quantity, in: modelContext)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .confirmationDialog(
            "\(product.name) arşivlensin mi?",
            isPresented: $isConfirmingArchive,
            titleVisibility: .visible
        ) {
            Button("Arşivle") {
                InventoryService.prepareForArchive(product, in: modelContext)
                archiveStore.archive(product)
                dismiss()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Ürün Ev ve Market Listesi'nden kaldırılacak. Geçmiş kayıtları silinmeyecek.")
        }
    }
}
