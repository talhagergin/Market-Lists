import Foundation
import SwiftData

enum StockStatus: String, Codable, CaseIterable, Identifiable {
    case available
    case low
    case outOfStock

    var id: String { rawValue }

    var title: String {
        switch self {
        case .available: String(localized: "Var")
        case .low: String(localized: "Azaldı")
        case .outOfStock: String(localized: "Bitti")
        }
    }

    var next: StockStatus {
        switch self {
        case .available: .low
        case .low: .outOfStock
        case .outOfStock: .available
        }
    }
}

enum ProductCategory: String, Codable, CaseIterable, Identifiable {
    case produce, dairy, protein, bakery, pantry, beverages, snacks, cleaning, personalCare, household, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .produce: String(localized: "Meyve & Sebze")
        case .dairy: String(localized: "Süt Ürünleri")
        case .protein: String(localized: "Et & Protein")
        case .bakery: String(localized: "Fırın")
        case .pantry: String(localized: "Kuru Gıda")
        case .beverages: String(localized: "İçecek")
        case .snacks: String(localized: "Atıştırmalık")
        case .cleaning: String(localized: "Temizlik")
        case .personalCare: String(localized: "Kişisel Bakım")
        case .household: String(localized: "Ev")
        case .other: String(localized: "Diğer")
        }
    }

    var symbol: String {
        switch self {
        case .produce: "carrot.fill"
        case .dairy: "waterbottle.fill"
        case .protein: "fish.fill"
        case .bakery: "birthday.cake.fill"
        case .pantry: "takeoutbag.and.cup.and.straw.fill"
        case .beverages: "cup.and.saucer.fill"
        case .snacks: "popcorn.fill"
        case .cleaning: "sparkles"
        case .personalCare: "shower.handheld.fill"
        case .household: "house.fill"
        case .other: "basket.fill"
        }
    }
}

@Model
final class Product {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var normalizedName: String
    var name: String
    var categoryRawValue: String
    var stockStatusRawValue: String
    var quantity: Int
    var isInShoppingList: Bool
    var purchaseCount: Int
    var lastPurchasedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    var category: ProductCategory {
        get { ProductCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }

    var stockStatus: StockStatus {
        get { StockStatus(rawValue: stockStatusRawValue) ?? .available }
        set { stockStatusRawValue = newValue.rawValue }
    }

    init(name: String, normalizedName: String, category: ProductCategory, stockStatus: StockStatus = .outOfStock, quantity: Int = 1, isInShoppingList: Bool = true) {
        self.id = UUID()
        self.name = name
        self.normalizedName = normalizedName
        self.categoryRawValue = category.rawValue
        self.stockStatusRawValue = stockStatus.rawValue
        self.quantity = quantity
        self.isInShoppingList = isInShoppingList
        self.purchaseCount = 0
        self.createdAt = .now
        self.updatedAt = .now
    }
}

@Model
final class PurchaseRecord {
    @Attribute(.unique) var id: UUID
    var productID: UUID
    var productName: String
    var quantity: Int
    var purchasedAt: Date

    init(product: Product, purchasedAt: Date = .now) {
        self.id = UUID()
        self.productID = product.id
        self.productName = product.name
        self.quantity = product.quantity
        self.purchasedAt = purchasedAt
    }
}
