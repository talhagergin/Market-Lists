import SwiftUI
import WidgetKit

struct WidgetListItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let quantity: Int
    let categoryRawValue: String
}

struct ShoppingListEntry: TimelineEntry {
    let date: Date
    let items: [WidgetListItem]
}

struct ShoppingListProvider: TimelineProvider {
    private let suiteName = "group.talhagergin.marketlistem"
    private let listKey = "widget.shopping-list"

    func placeholder(in context: Context) -> ShoppingListEntry {
        ShoppingListEntry(date: .now, items: Self.samples)
    }

    func getSnapshot(in context: Context, completion: @escaping (ShoppingListEntry) -> Void) {
        completion(ShoppingListEntry(date: .now, items: context.isPreview ? Self.samples : loadItems()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShoppingListEntry>) -> Void) {
        let entry = ShoppingListEntry(date: .now, items: loadItems())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func loadItems() -> [WidgetListItem] {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: listKey),
              let items = try? JSONDecoder().decode([WidgetListItem].self, from: data)
        else { return [] }
        return items
    }

    private static let samples = [
        WidgetListItem(id: UUID(), name: "Süt", quantity: 2, categoryRawValue: "dairy"),
        WidgetListItem(id: UUID(), name: "Yumurta", quantity: 12, categoryRawValue: "protein"),
        WidgetListItem(id: UUID(), name: "Ekmek", quantity: 1, categoryRawValue: "bakery")
    ]
}

struct ShoppingListWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ShoppingListEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Label("Market Listem", systemImage: "basket.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                Spacer()
                Text("\(entry.items.count)")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.12), in: Capsule())
            }

            if entry.items.isEmpty {
                VStack(spacing: 7) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text("Listen boş")
                        .font(.subheadline.weight(.semibold))
                    Text("Alınacak ürün bulunmuyor.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if family == .systemSmall {
                VStack(spacing: 7) {
                    ForEach(entry.items.prefix(3)) { item in
                        productRow(item)
                    }
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7) {
                    ForEach(entry.items.prefix(6)) { item in
                        productRow(item)
                    }
                }
            }

            if entry.items.count > visibleLimit {
                Text("+\(entry.items.count - visibleLimit) ürün daha")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.background, for: .widget)
        .accessibilityElement(children: .contain)
    }

    private var visibleLimit: Int { family == .systemSmall ? 3 : 6 }

    private func productRow(_ item: WidgetListItem) -> some View {
        HStack(spacing: 7) {
            productImage(for: item)
                .frame(width: 27, height: 27)
            Text(item.name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            Spacer(minLength: 2)
            if item.quantity > 1 {
                Text("×\(item.quantity)")
                    .font(.caption2.bold().monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 29)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.name)
        .accessibilityValue("\(item.quantity) adet")
    }

    @ViewBuilder
    private func productImage(for item: WidgetListItem) -> some View {
        if let assetName = assetName(for: item.name) {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: symbol(for: item.categoryRawValue))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private func assetName(for name: String) -> String? {
        let normalized = name
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "tr_TR"))
            .lowercased(with: Locale(identifier: "tr_TR"))
        let assets = [
            "sut": "ProductMilk", "yumurta": "ProductEgg", "ekmek": "ProductBread",
            "kahve": "ProductCoffee", "tuvalet kagıdı": "ProductToiletPaper", "sampuan": "ProductShampoo"
        ]
        return assets.first { normalized == $0.key || normalized.contains($0.key) }?.value
    }

    private func symbol(for category: String) -> String {
        switch category {
        case "produce": "carrot.fill"
        case "dairy": "waterbottle.fill"
        case "protein": "fish.fill"
        case "bakery": "birthday.cake.fill"
        case "beverages": "cup.and.saucer.fill"
        case "cleaning": "sparkles"
        case "personalCare": "shower.handheld.fill"
        default: "basket.fill"
        }
    }
}

struct MarketListemWidget: Widget {
    let kind = "MarketListemQuickAddWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShoppingListProvider()) { entry in
            ShoppingListWidgetView(entry: entry)
        }
        .configurationDisplayName("Market Listem")
        .description("Alınacak ürünlerini ve adetlerini ana ekranda gör.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct MarketListemWidgetBundle: WidgetBundle {
    var body: some Widget {
        MarketListemWidget()
    }
}
