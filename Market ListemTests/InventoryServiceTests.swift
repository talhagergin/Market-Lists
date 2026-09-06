import Foundation
import SwiftData
import Testing
@testable import Market_Listem

@MainActor
struct InventoryServiceTests {
    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Product.self,
            PurchaseRecord.self,
            configurations: configuration
        )
        return ModelContext(container)
    }

    @Test("Ürün sözlüğü açıklamalı ürün adlarını kategoriler")
    func categoryVariants() {
        #expect(ProductCatalog.category(for: "Tam yağlı süt") == .dairy)
        #expect(ProductCatalog.category(for: "Organik yumurta") == .protein)
        #expect(ProductCatalog.category(for: "Beyaz peynir") == .dairy)
        #expect(ProductCatalog.category(for: "Bilinmeyen ürün") == .other)
        #expect(ProductCatalog.category(for: "Whole milk") == .dairy)
        #expect(ProductCatalog.category(for: "Organic eggs") == .protein)
        #expect(ProductCatalog.category(for: "Dish soap") == .cleaning)
    }

    @Test("Ürün görseli doğrudan eşleşir ve kategori fallback'i kullanır")
    func productEmoji() {
        #expect(ProductCatalog.emoji(for: "Organik yumurta") == "🥚")
        #expect(ProductCatalog.emoji(for: "Bilinmeyen temizlik ürünü", category: .cleaning) == "🧽")
        #expect(ProductCatalog.symbol(for: "Tam yağlı süt") == "waterbottle.fill")
        #expect(ProductCatalog.symbol(for: "Bilinmeyen ürün", category: .other) == ProductCategory.other.symbol)
        #expect(ProductCatalog.assetName(for: "Organik yumurta") == "ProductEgg")
        #expect(ProductCatalog.assetName(for: "Bilinmeyen ürün") == nil)
        #expect(ProductCatalog.assetName(for: "Whole milk") == "ProductMilk")
    }

    @Test("Alışveriş oturumu ilerlemeyi ve tamamlananları takip eder")
    func shoppingSessionProgress() {
        let product = Product(name: "Süt", normalizedName: "sut", category: .dairy)
        var session = ShoppingSession()

        #expect(session.progress(remainingCount: 3) == 0)
        session.record(product)

        #expect(session.purchasedCount == 1)
        #expect(session.totalCount(remainingCount: 2) == 3)
        #expect(session.progress(remainingCount: 2) == 1.0 / 3.0)

        session.record(product)
        #expect(session.purchasedCount == 1)

        session.reset()
        #expect(session.purchased.isEmpty)
    }

    @Test("Liste filtresi Türkçe aramayı ve kategoriyi birlikte uygular")
    func productFiltering() {
        let milk = Product(name: "Süt", normalizedName: ProductCatalog.normalize("Süt"), category: .dairy)

        #expect(ProductFilter.matches(milk, searchText: "sut", category: nil))
        #expect(ProductFilter.matches(milk, searchText: "SÜ", category: .dairy))
        #expect(!ProductFilter.matches(milk, searchText: "kahve", category: nil))
        #expect(!ProductFilter.matches(milk, searchText: "", category: .produce))
    }

    @Test("Yeni ürün normalize edilir, kategorilenir ve listeye eklenir")
    func addProduct() throws {
        let context = try makeContext()

        let result = InventoryService.addToShoppingList(named: "  süt  ", in: context)

        guard case .added(let product) = result else {
            Issue.record("Ürün eklenmeliydi")
            return
        }
        #expect(product.name == "Süt")
        #expect(product.normalizedName == "sut")
        #expect(product.category == .dairy)
        #expect(product.stockStatus == .outOfStock)
        #expect(product.isInShoppingList)
    }

    @Test("Yeni ürün seçilen adetle eklenir")
    func addProductWithQuantity() throws {
        let context = try makeContext()

        let result = InventoryService.addToShoppingList(named: "Yumurta", quantity: 12, in: context)

        guard case .added(let product) = result else {
            Issue.record("Ürün eklenmeliydi")
            return
        }
        #expect(product.quantity == 12)
    }

    @Test("Aynı ürün farklı büyük-küçük harfle çoğaltılmaz")
    func duplicateProduct() throws {
        let context = try makeContext()
        _ = InventoryService.addToShoppingList(named: "Şampuan", in: context)

        let duplicate = InventoryService.addToShoppingList(named: " şAMPUAN ", in: context)
        let products = try context.fetch(FetchDescriptor<Product>())

        guard case .alreadyListed = duplicate else {
            Issue.record("Duplicate ürün algılanmalıydı")
            return
        }
        #expect(products.count == 1)
    }

    @Test("Bitti durumu ürünü otomatik olarak market listesine taşır")
    func outOfStockAddsToList() throws {
        let context = try makeContext()
        let product = Product(
            name: "Kahve",
            normalizedName: "kahve",
            category: .pantry,
            stockStatus: .available,
            isInShoppingList: false
        )
        context.insert(product)

        InventoryService.setStatus(.outOfStock, for: product, in: context)

        #expect(product.stockStatus == .outOfStock)
        #expect(product.isInShoppingList)
    }

    @Test("Satın alma stoğu yeniler ve geçmiş kaydı oluşturur")
    func purchaseCompletesCycle() throws {
        let context = try makeContext()
        let product = Product(name: "Ekmek", normalizedName: "ekmek", category: .bakery, quantity: 2)
        context.insert(product)

        InventoryService.purchase(product, in: context)
        let history = try context.fetch(FetchDescriptor<PurchaseRecord>())

        #expect(product.stockStatus == .available)
        #expect(!product.isInShoppingList)
        #expect(product.purchaseCount == 1)
        #expect(product.lastPurchasedAt != nil)
        #expect(history.count == 1)
        #expect(history.first?.productName == "Ekmek")
        #expect(history.first?.quantity == 2)
    }

    @Test("Geçmişten eklenen mevcut ürün yeni kayıt oluşturmaz")
    func reAddExistingProduct() throws {
        let context = try makeContext()
        let product = Product(
            name: "Yumurta",
            normalizedName: "yumurta",
            category: .protein,
            stockStatus: .available,
            isInShoppingList: false
        )
        context.insert(product)
        try context.save()

        let result = InventoryService.addToShoppingList(named: "Yumurta", in: context)
        let products = try context.fetch(FetchDescriptor<Product>())

        guard case .restored(let restored, let previousStatus) = result else {
            Issue.record("Mevcut ürün yeniden listeye alınmalıydı")
            return
        }
        #expect(restored.id == product.id)
        #expect(restored.isInShoppingList)
        #expect(restored.stockStatus == .outOfStock)
        #expect(previousStatus == .available)
        #expect(products.count == 1)
    }

    @Test("Hızlı ekleme geri alındığında yeni ürün kaldırılır")
    func undoNewQuickAddition() throws {
        let context = try makeContext()
        let result = InventoryService.addToShoppingList(named: "Muz", in: context)
        let undo = try #require(InventoryService.undoToken(for: result))

        InventoryService.undoAddition(undo, in: context)

        #expect(try context.fetch(FetchDescriptor<Product>()).isEmpty)
    }

    @Test("Mevcut ürünün hızlı eklemesi geri alındığında önceki durumu korunur")
    func undoRestoredQuickAddition() throws {
        let context = try makeContext()
        let product = Product(
            name: "Kahve",
            normalizedName: "kahve",
            category: .pantry,
            stockStatus: .low,
            isInShoppingList: false
        )
        context.insert(product)
        try context.save()

        let result = InventoryService.addToShoppingList(named: "Kahve", in: context)
        let undo = try #require(InventoryService.undoToken(for: result))
        InventoryService.undoAddition(undo, in: context)

        #expect(!product.isInShoppingList)
        #expect(product.stockStatus == .low)
        #expect(try context.fetch(FetchDescriptor<Product>()).count == 1)
    }

    @Test("Arşiv durumu yerel olarak saklanır ve geri yüklenir")
    func productArchiving() throws {
        let suiteName = "ProductArchiveStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let product = Product(name: "Deterjan", normalizedName: "deterjan", category: .cleaning)

        let store = ProductArchiveStore(defaults: defaults)
        store.archive(product)
        #expect(store.contains(product))

        let reloadedStore = ProductArchiveStore(defaults: defaults)
        #expect(reloadedStore.contains(product))
        reloadedStore.restore(product)
        #expect(!reloadedStore.contains(product))
    }
}
