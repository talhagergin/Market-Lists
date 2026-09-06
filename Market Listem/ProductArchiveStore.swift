import Foundation
import Observation

@MainActor
@Observable
final class ProductArchiveStore {
    private(set) var productIDs: Set<UUID>
    private let defaults: UserDefaults
    private let storageKey: String

    init(defaults: UserDefaults = .standard, storageKey: String = "archivedProductIDs") {
        self.defaults = defaults
        self.storageKey = storageKey
        self.productIDs = Set(
            defaults.stringArray(forKey: storageKey)?.compactMap(UUID.init(uuidString:)) ?? []
        )
    }

    func contains(_ product: Product) -> Bool {
        productIDs.contains(product.id)
    }

    func archive(_ product: Product) {
        productIDs.insert(product.id)
        persist()
    }

    func restore(_ product: Product) {
        productIDs.remove(product.id)
        persist()
    }

    private func persist() {
        defaults.set(productIDs.map(\.uuidString).sorted(), forKey: storageKey)
    }
}
