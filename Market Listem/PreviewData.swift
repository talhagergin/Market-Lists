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
            (String(localized: "Süt"), .dairy, .outOfStock, true, 2),
            (String(localized: "Yumurta"), .protein, .outOfStock, true, 1),
            (String(localized: "Ekmek"), .bakery, .outOfStock, true, 1),
            (String(localized: "Muz"), .produce, .outOfStock, true, 6),
            (String(localized: "Kahve"), .pantry, .low, false, 1),
            (String(localized: "Şampuan"), .personalCare, .low, false, 1),
            (String(localized: "Deterjan"), .cleaning, .available, false, 1)
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
