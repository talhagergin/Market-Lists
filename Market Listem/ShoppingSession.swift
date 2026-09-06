import Foundation

struct PurchasedSnapshot: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: ProductCategory
    let quantity: Int
}

struct ShoppingSession {
    private(set) var purchased: [PurchasedSnapshot] = []

    var purchasedCount: Int { purchased.count }

    func totalCount(remainingCount: Int) -> Int {
        remainingCount + purchasedCount
    }

    func progress(remainingCount: Int) -> Double {
        let total = totalCount(remainingCount: remainingCount)
        guard total > 0 else { return 0 }
        return Double(purchasedCount) / Double(total)
    }

    mutating func record(_ product: Product) {
        guard !purchased.contains(where: { $0.id == product.id }) else { return }
        purchased.append(
            PurchasedSnapshot(
                id: product.id,
                name: product.name,
                category: product.category,
                quantity: product.quantity
            )
        )
    }

    mutating func reset() {
        purchased.removeAll()
    }
}
