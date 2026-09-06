import SwiftUI
import SwiftData

struct ArchivedProductsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProductArchiveStore.self) private var archiveStore
    @Query(sort: \Product.name) private var products: [Product]

    private var archivedProducts: [Product] {
        products.filter(archiveStore.contains)
    }

    var body: some View {
        NavigationStack {
            Group {
                if archivedProducts.isEmpty {
                    ContentUnavailableView(
                        "Arşiv boş",
                        systemImage: "archivebox",
                        description: Text("Takipten çıkardığın ürünler burada görünür.")
                    )
                } else {
                    List(archivedProducts) { product in
                        HStack(spacing: 14) {
                            ProductThumbnail(name: product.name, category: product.category)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(product.name).font(.body.weight(.semibold))
                                Text(product.category.title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Geri Yükle") {
                                withAnimation(.snappy) { archiveStore.restore(product) }
                                Feedback.success()
                            }
                            .buttonStyle(.borderless)
                            .font(.subheadline.weight(.semibold))
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(product.name)
                        .accessibilityValue("Arşivlendi")
                        .accessibilityAction(named: "Geri Yükle") { archiveStore.restore(product) }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Arşiv")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitti") { dismiss() }
                }
            }
        }
    }
}
