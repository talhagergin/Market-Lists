import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ProductArchiveStore.self) private var archiveStore
    @Query(sort: \PurchaseRecord.purchasedAt, order: .reverse) private var records: [PurchaseRecord]

    private var groupedRecords: [(Date, [PurchaseRecord])] {
        let calendar = Calendar.current
        return Dictionary(grouping: records) { calendar.startOfDay(for: $0.purchasedAt) }
            .sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView {
                        Label("Henüz geçmiş yok", systemImage: "clock.arrow.circlepath")
                    } description: {
                        Text("Satın aldığın ürünler burada görünecek.")
                    }
                } else {
                    List {
                        ForEach(groupedRecords, id: \.0) { date, items in
                            Section(dayTitle(date)) {
                                ForEach(items) { record in
                                    HStack(spacing: 14) {
                                        ProductThumbnail(
                                            name: record.productName,
                                            category: ProductCatalog.category(for: record.productName),
                                            size: 40
                                        )
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(record.productName)
                                                .font(.body.weight(.medium))
                                            Text(record.purchasedAt, format: .dateTime.hour().minute())
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        if record.quantity > 1 {
                                            Text("×\(record.quantity)")
                                                .foregroundStyle(.secondary)
                                        }
                                        Button("Tekrar Ekle") {
                                            let result = InventoryService.addToShoppingList(named: record.productName, in: modelContext)
                                            handleRepeatResult(result)
                                        }
                                        .buttonStyle(.borderless)
                                        .font(.caption.weight(.semibold))
                                        .accessibilityIdentifier("history.readd.\(ProductCatalog.normalize(record.productName))")
                                    }
                                    .padding(.vertical, 4)
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel(record.productName)
                                    .accessibilityValue("\(record.quantity) adet, \(record.purchasedAt.formatted(date: .abbreviated, time: .shortened)) tarihinde alındı")
                                    .accessibilityAction(named: "Tekrar Ekle") {
                                        handleRepeatResult(
                                            InventoryService.addToShoppingList(named: record.productName, in: modelContext)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Geçmiş")
        }
    }

    private func dayTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Bugün" }
        if calendar.isDateInYesterday(date) { return "Dün" }
        return date.formatted(.dateTime.day().month(.wide).year())
    }

    private func handleRepeatResult(_ result: InventoryService.AddResult) {
        switch result {
        case .added(let product), .restored(let product, _):
            archiveStore.restore(product)
            Feedback.success()
        case .alreadyListed:
            Feedback.selection()
        case .invalid:
            break
        }
    }
}
