import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Product.createdAt) private var products: [Product]
    @State private var isAddingProduct = false
    @State private var isShoppingMode = false
    @State private var selectedProduct: Product?
    @State private var shoppingSession = ShoppingSession()
    @State private var searchText = ""
    @State private var selectedCategory: ProductCategory?

    private var listedProducts: [Product] { products.filter(\.isInShoppingList) }
    private var visibleProducts: [Product] {
        listedProducts.filter {
            ProductFilter.matches($0, searchText: searchText, category: selectedCategory)
        }
    }
    private var groupedProducts: [(ProductCategory, [Product])] {
        ProductCategory.allCases.compactMap { category in
            let matches = visibleProducts.filter { $0.category == category }
            return matches.isEmpty ? nil : (category, matches)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if listedProducts.isEmpty && shoppingSession.purchased.isEmpty {
                    ContentUnavailableView {
                        Label("Listen boş", systemImage: "basket")
                    } description: {
                        Text("Şimdilik alınacak bir şey görünmüyor.")
                    } actions: {
                        Button("Ürün Ekle") { isAddingProduct = true }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .accessibilityIdentifier("shopping.add.empty")
                    }
                } else {
                    List {
                        header
                            .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 18, trailing: 20))
                            .listRowBackground(Color.clear)

                        if visibleProducts.isEmpty && shoppingSession.purchased.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                                .listRowBackground(Color.clear)
                        }

                        ForEach(groupedProducts, id: \.0) { category, items in
                            Section {
                                ForEach(items) { product in
                                    productRow(product)
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button("Alındı", systemImage: "checkmark") { purchase(product) }
                                                .tint(.green)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button("Çıkar", systemImage: "trash") {
                                                withAnimation { InventoryService.removeFromShoppingList(product, in: modelContext) }
                                            }
                                            .tint(.red)
                                        }
                                }
                            } header: {
                                Label(category.title.uppercased(), systemImage: category.symbol)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if isShoppingMode && !shoppingSession.purchased.isEmpty {
                            completedSection
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(isShoppingMode ? "Market" : "Market Listem")
            .searchable(text: $searchText, prompt: "Ürün ara")
            .toolbar {
                if !listedProducts.isEmpty && !isShoppingMode {
                    ToolbarItem(placement: .topBarLeading) {
                        categoryMenu
                    }
                }
                if !listedProducts.isEmpty || isShoppingMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(isShoppingMode ? "Bitir" : "Alışverişe Başla") {
                            withAnimation(.snappy) {
                                if isShoppingMode { shoppingSession.reset() }
                                isShoppingMode.toggle()
                            }
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !isShoppingMode && !listedProducts.isEmpty {
                    Button { isAddingProduct = true } label: {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .frame(width: 58, height: 58)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(.green)
                    .shadow(color: .black.opacity(0.16), radius: 12, y: 6)
                    .padding(22)
                    .accessibilityLabel("Ürün ekle")
                    .accessibilityIdentifier("shopping.add.fab")
                }
            }
            .sheet(isPresented: $isAddingProduct) { AddProductSheet() }
            .sheet(item: $selectedProduct) { ProductDetailSheet(product: $0) }
        }
    }

    private var categoryMenu: some View {
        Menu {
            Button {
                selectedCategory = nil
            } label: {
                if selectedCategory == nil {
                    Label("Tüm Kategoriler", systemImage: "checkmark")
                } else {
                    Text("Tüm Kategoriler")
                }
            }

            ForEach(ProductCategory.allCases) { category in
                Button {
                    selectedCategory = category
                } label: {
                    if selectedCategory == category {
                        Label(category.title, systemImage: "checkmark")
                    } else {
                        Label(category.title, systemImage: category.symbol)
                    }
                }
            }
        } label: {
            Label(selectedCategory?.title ?? "Filtre", systemImage: "line.3.horizontal.decrease")
        }
        .accessibilityLabel("Kategori filtresi")
        .accessibilityValue(selectedCategory?.title ?? "Tüm kategoriler")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isShoppingMode ? "ALIŞVERİŞ MODU" : "HAZIRLIK")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.green)
                Text(headerCountText)
                    .font(.title2.bold())
            }
            Spacer()
            if isShoppingMode {
                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding(18)
        .background(.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .bottom) {
            if isShoppingMode {
                ProgressView(value: shoppingSession.progress(remainingCount: listedProducts.count))
                    .tint(.green)
                    .padding(.horizontal, 18)
                    .offset(y: -8)
                    .accessibilityLabel("Alışveriş ilerlemesi")
                    .accessibilityValue(headerCountText)
            }
        }
    }

    private var headerCountText: String {
        if isShoppingMode {
            return "\(shoppingSession.purchasedCount) / \(shoppingSession.totalCount(remainingCount: listedProducts.count)) alındı"
        }
        return "\(listedProducts.count) ürün kaldı"
    }

    private var completedSection: some View {
        Section {
            ForEach(shoppingSession.purchased) { item in
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    ProductThumbnail(name: item.name, category: item.category, size: 38)
                    Text(item.name)
                        .foregroundStyle(.secondary)
                        .strikethrough()
                    Spacer()
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(minHeight: 50)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(item.name)
                .accessibilityValue("Alındı")
            }
        } header: {
            Label("ALINANLAR", systemImage: "checkmark.circle.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
    }

    private func productRow(_ product: Product) -> some View {
        Button { selectedProduct = product } label: {
            HStack(spacing: 14) {
                Button { purchase(product) } label: {
                    Image(systemName: "circle")
                        .font(isShoppingMode ? .title : .title2)
                        .foregroundStyle(.green)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(product.name) alındı")

                ProductThumbnail(name: product.name, category: product.category, size: isShoppingMode ? 46 : 38)

                Text(product.name)
                    .font(isShoppingMode ? .title3.weight(.semibold) : .body.weight(.medium))
                    .foregroundStyle(.primary)
                Spacer()
                if product.quantity > 1 {
                    Text("×\(product.quantity)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: isShoppingMode ? 58 : 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(product.name)
        .accessibilityValue(product.quantity > 1 ? "\(product.quantity) adet, \(product.category.title)" : product.category.title)
        .accessibilityHint("Detayları düzenlemek için çift dokun")
        .accessibilityIdentifier("product.row.\(ProductCatalog.normalize(product.name))")
        .accessibilityAction(named: "Alındı") { purchase(product) }
    }

    private func purchase(_ product: Product) {
        Feedback.success()
        withAnimation(.snappy) {
            if isShoppingMode { shoppingSession.record(product) }
            InventoryService.purchase(product, in: modelContext)
        }
    }
}
