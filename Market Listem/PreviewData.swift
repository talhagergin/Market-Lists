#if DEBUG
import Foundation
import SwiftData

@MainActor
enum PreviewData {
    static func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Product.self,
            PurchaseRecord.self,
            configurations: configuration
        )
        let context = container.mainContext

        let samples: [(String, ProductCategory, StockStatus, Bool, Int)] = [
            ("Süt", .dairy, .outOfStock, true, 2),
            ("Yumurta", .protein, .outOfStock, true, 1),
            ("Ekmek", .bakery, .outOfStock, true, 1),
            ("Muz", .produce, .outOfStock, true, 6),
            ("Kahve", .pantry, .low, false, 1),
            ("Şampuan", .personalCare, .low, false, 1),
            ("Deterjan", .cleaning, .available, false, 1)
        ]

        for (name, category, status, isListed, quantity) in samples {
            let product = Product(
                name: name,
                normalizedName: ProductCatalog.normalize(name),
                category: category,
                stockStatus: status,
                quantity: quantity,
                isInShoppingList: isListed
            )
            context.insert(product)
        }
        try context.save()
        return container
    }
}
#endif
