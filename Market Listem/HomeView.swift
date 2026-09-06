import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ProductArchiveStore.self) private var archiveStore
    @Query(sort: \Product.updatedAt, order: .reverse) private var products: [Product]
    @State private var selectedProduct: Product?
    @State private var showAddedConfirmation = false
    @State private var additionUndo: InventoryService.AdditionUndo?
    @State private var rearchiveOnUndo = false
    @State private var isShowingArchive = false

    private var activeProducts: [Product] { products.filter { !archiveStore.contains($0) } }
    private var lowProducts: [Product] { activeProducts.filter { $0.stockStatus == .low } }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    if !lowProducts.isEmpty { lowSection }
                    quickAddSection
                    inventorySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Evdekiler")
            .toolbar {
                if !archiveStore.productIDs.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Arşiv", systemImage: "archivebox") { isShowingArchive = true }
                    }
                }
            }
            .sheet(item: $selectedProduct) { ProductDetailSheet(product: $0) }
            .sheet(isPresented: $isShowingArchive) { ArchivedProductsView() }
            .overlay(alignment: .top) {
                if showAddedConfirmation {
                    HStack(spacing: 14) {
                        Label("Listeye eklendi", systemImage: "checkmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                        if let additionUndo {
                            Button("Geri Al") {
                                InventoryService.undoAddition(additionUndo, in: modelContext)
                                if rearchiveOnUndo { archiveStore.archive(additionUndo.product) }
                                withAnimation(.snappy) {
                                    showAddedConfirmation = false
                                    self.additionUndo = nil
                                    rearchiveOnUndo = false
                                }
                            }
                            .font(.subheadline.bold())
                        }
                    }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
        }
    }

    private var lowSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Azalanlar")
                        .font(.title3.bold())
                    Text("Marketten önce göz at")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Tümünü Ekle") {
                    lowProducts.forEach { InventoryService.addExistingToList($0, in: modelContext) }
                    confirmAddition()
                }
                .font(.subheadline.weight(.semibold))
                .disabled(lowProducts.allSatisfy(\.isInShoppingList))
            }

            ForEach(lowProducts.prefix(3)) { product in
                HStack {
                    ProductThumbnail(name: product.name, category: product.category, size: 34)
                    Text(product.name)
                    Spacer()
                    if product.isInShoppingList {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.secondary)
                    } else {
                        Button("Ekle") {
                            InventoryService.addExistingToList(product, in: modelContext)
                            confirmAddition()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
        .padding(18)
        .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 22))
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Hızlı Eksik Ekle")
                .font(.title3.bold())
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                ForEach(rankedSuggestions) { suggestion in
                    Button {
                        let result = InventoryService.addToShoppingList(named: suggestion.localizedName, in: modelContext)
                        switch result {
                        case .alreadyListed:
                            Feedback.selection()
                        case .added(let product), .restored(let product, _):
                            let wasArchived = archiveStore.contains(product)
                            archiveStore.restore(product)
                            confirmAddition(
                                undo: InventoryService.undoToken(for: result),
                                rearchiveOnUndo: wasArchived
                            )
                        case .invalid:
                            break
                        }
                    } label: {
                        HStack(spacing: 10) {
                            ProductThumbnail(
                                name: suggestion.localizedName,
                                category: ProductCatalog.category(for: suggestion.localizedName),
                                size: 36
                            )
                            Text(suggestion.localizedName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.format("%@ listeye ekle", suggestion.localizedName))
                    .accessibilityHint("Market listesine eklemek için çift dokun")
                }
            }
        }
    }

    @ViewBuilder
    private var inventorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tüm Ürünler")
                .font(.title3.bold())

            if activeProducts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "house.and.flag")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("Evde düzenli kullandığın ürünleri ekle.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(activeProducts) { product in
                    Button {
                        Feedback.selection()
                        withAnimation(.snappy) { InventoryService.cycleStatus(for: product, in: modelContext) }
                    } label: {
                        HStack(spacing: 14) {
                            ProductThumbnail(name: product.name, category: product.category, size: 44)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(product.name)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(product.category.title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(product.stockStatus.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(statusColor(product.stockStatus))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(statusColor(product.stockStatus).opacity(0.11), in: Capsule())
                        }
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        ForEach(StockStatus.allCases) { status in
                            Button(status.title) { InventoryService.setStatus(status, for: product, in: modelContext) }
                        }
                        Button("Detayları Düzenle", systemImage: "slider.horizontal.3") { selectedProduct = product }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(product.name)
                    .accessibilityValue("\(product.stockStatus.title), \(product.category.title)")
                    .accessibilityHint("Bir sonraki stok durumuna geçirmek için çift dokun")
                    .accessibilityAction(named: "Listeye Ekle") {
                        InventoryService.addExistingToList(product, in: modelContext)
                    }
                    .accessibilityAction(named: "Detayları Düzenle") { selectedProduct = product }
                }
            }
        }
    }

    private var rankedSuggestions: [ProductCatalog.Suggestion] {
        ProductCatalog.quickSuggestions.sorted { lhs, rhs in
            let leftNames = [lhs.name, lhs.localizedName].map { ProductCatalog.normalize($0) }
            let rightNames = [rhs.name, rhs.localizedName].map { ProductCatalog.normalize($0) }
            let leftCount = products.first { leftNames.contains($0.normalizedName) }?.purchaseCount ?? 0
            let rightCount = products.first { rightNames.contains($0.normalizedName) }?.purchaseCount ?? 0
            return leftCount > rightCount
        }
    }

    private func statusColor(_ status: StockStatus) -> Color {
        switch status {
        case .available: .green
        case .low: .orange
        case .outOfStock: .red
        }
    }

    private func confirmAddition(
        undo: InventoryService.AdditionUndo? = nil,
        rearchiveOnUndo: Bool = false
    ) {
        Feedback.success()
        withAnimation(.snappy) {
            additionUndo = undo
            self.rearchiveOnUndo = rearchiveOnUndo
            showAddedConfirmation = true
        }
        let undoID = undo?.id
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard additionUndo?.id == undoID else { return }
            withAnimation(.snappy) {
                showAddedConfirmation = false
                additionUndo = nil
                self.rearchiveOnUndo = false
            }
        }
    }
}
