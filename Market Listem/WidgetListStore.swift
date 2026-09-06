import Foundation
import WidgetKit

struct WidgetListItem: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let quantity: Int
    let categoryRawValue: String
}

enum WidgetListStore {
    static let suiteName = "group.talhagergin.marketlistem"
    static let listKey = "widget.shopping-list"
    static let widgetKind = "MarketListemQuickAddWidget"

    static func save(_ items: [WidgetListItem]) {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = try? JSONEncoder().encode(items)
        else { return }

        defaults.set(data, forKey: listKey)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }
}
