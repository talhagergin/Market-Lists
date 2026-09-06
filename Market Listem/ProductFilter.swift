import Foundation

enum ProductFilter {
    static func matches(_ product: Product, searchText: String, category: ProductCategory?) -> Bool {
        let normalizedSearch = ProductCatalog.normalize(searchText)
        let matchesSearch = normalizedSearch.isEmpty || product.normalizedName.contains(normalizedSearch)
        let matchesCategory = category == nil || product.category == category
        return matchesSearch && matchesCategory
    }
}
