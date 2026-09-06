import Foundation
import SwiftData

@MainActor
enum InventoryService {
    enum AddResult {
        case added(Product)
        case restored(Product, previousStatus: StockStatus)
        case alreadyListed(Product)
        case invalid
    }

    struct AdditionUndo: Identifiable {
        let id = UUID()
        let product: Product
        let deletesProduct: Bool
        let previousStatus: StockStatus?
    }

    static func addToShoppingList(named rawName: String, quantity: Int = 1, in context: ModelContext) -> AddResult {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedName = ProductCatalog.normalize(name)
        guard !normalizedName.isEmpty else { return .invalid }
        let safeQuantity = min(max(quantity, 1), 99)

        var descriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.normalizedName == normalizedName })
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            guard !existing.isInShoppingList else { return .alreadyListed(existing) }
            let previousStatus = existing.stockStatus
            existing.isInShoppingList = true
            existing.stockStatus = .outOfStock
            existing.quantity = safeQuantity
            existing.updatedAt = .now
            save(context)
            return .restored(existing, previousStatus: previousStatus)
        }

        let displayName = name.prefix(1).uppercased(with: Locale(identifier: "tr_TR")) + name.dropFirst()
        let product = Product(
            name: displayName,
            normalizedName: normalizedName,
            category: ProductCatalog.category(for: name),
            quantity: safeQuantity
        )
        context.insert(product)
        save(context)
        return .added(product)
    }

    static func undoToken(for result: AddResult) -> AdditionUndo? {
        switch result {
        case .added(let product):
            AdditionUndo(product: product, deletesProduct: true, previousStatus: nil)
        case .restored(let product, let previousStatus):
            AdditionUndo(product: product, deletesProduct: false, previousStatus: previousStatus)
        case .alreadyListed, .invalid:
            nil
        }
    }

    static func undoAddition(_ undo: AdditionUndo, in context: ModelContext) {
        if undo.deletesProduct {
            context.delete(undo.product)
        } else {
            undo.product.isInShoppingList = false
            undo.product.stockStatus = undo.previousStatus ?? .available
            undo.product.updatedAt = .now
        }
        save(context)
    }

    static func purchase(_ product: Product, in context: ModelContext) {
        context.insert(PurchaseRecord(product: product))
        product.isInShoppingList = false
        product.stockStatus = .available
        product.purchaseCount += 1
        product.lastPurchasedAt = .now
        product.updatedAt = .now
        save(context)
    }

    static func removeFromShoppingList(_ product: Product, in context: ModelContext) {
        product.isInShoppingList = false
        if product.stockStatus == .outOfStock { product.stockStatus = .low }
        product.updatedAt = .now
        save(context)
    }

    static func setStatus(_ status: StockStatus, for product: Product, in context: ModelContext) {
        product.stockStatus = status
        if status == .outOfStock { product.isInShoppingList = true }
        if status == .available { product.isInShoppingList = false }
        product.updatedAt = .now
        save(context)
    }

    static func cycleStatus(for product: Product, in context: ModelContext) {
        setStatus(product.stockStatus.next, for: product, in: context)
    }

    static func addExistingToList(_ product: Product, in context: ModelContext) {
        guard !product.isInShoppingList else { return }
        product.isInShoppingList = true
        product.updatedAt = .now
        save(context)
    }

    static func update(_ product: Product, category: ProductCategory, quantity: Int, in context: ModelContext) {
        product.category = category
        product.quantity = max(1, quantity)
        product.updatedAt = .now
        save(context)
    }

    static func prepareForArchive(_ product: Product, in context: ModelContext) {
        product.isInShoppingList = false
        product.stockStatus = .available
        product.updatedAt = .now
        save(context)
    }

    private static func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            NotificationCenter.default.post(
                name: .inventoryPersistenceError,
                object: nil,
                userInfo: ["message": error.localizedDescription]
            )
        }
    }
}
