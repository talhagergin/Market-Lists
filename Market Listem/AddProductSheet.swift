import SwiftUI
import SwiftData

struct AddProductSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ProductArchiveStore.self) private var archiveStore
    @State private var name = ""
    @State private var quantity = 1
    @State private var duplicateMessage: String?
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ne eksik?")
                        .font(.largeTitle.bold())
                    Text("Sadece adını yaz. Kategorisini biz buluruz.")
                        .foregroundStyle(.secondary)
                }

                TextField("Örn. Süt", text: $name)
                    .font(.title3)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($isNameFocused)
                    .onSubmit(add)
                    .padding(16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel("Ürün adı")
                    .accessibilityIdentifier("product.name.field")

                Stepper(value: $quantity, in: 1...99) {
                    HStack {
                        Text("Adet")
                        Spacer()
                        Text("\(quantity)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.green)
                    }
                }
                .padding(16)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("Ürün adedi")
                .accessibilityValue("\(quantity)")
                .accessibilityIdentifier("product.quantity.stepper")

                if let duplicateMessage {
                    Label(duplicateMessage, systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .accessibilityIdentifier("product.duplicate.message")
                }

                Button(action: add) {
                    Text("Listeye Ekle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("product.add.button")

                Spacer()
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear { isNameFocused = true }
    }

    private func add() {
        switch InventoryService.addToShoppingList(named: name, quantity: quantity, in: modelContext) {
        case .added(let product), .restored(let product, _):
            archiveStore.restore(product)
            Feedback.success()
            dismiss()
        case .alreadyListed(let product):
            withAnimation { duplicateMessage = "\(product.name) zaten listende." }
            Feedback.selection()
        case .invalid:
            break
        }
    }
}
