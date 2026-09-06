import SwiftUI

struct OnboardingView: View {
    struct Page: Identifiable {
        let id: Int
        let symbol: String
        let title: String
        let description: String
        let tint: Color
    }

    let onComplete: () -> Void
    @State private var selection = 0

    private let pages = [
        Page(
            id: 0,
            symbol: "house.fill",
            title: String(localized: "Evde ne var, bil"),
            description: String(localized: "Düzenli kullandığın ürünlerin durumunu Var, Azaldı veya Bitti olarak takip et."),
            tint: .green
        ),
        Page(
            id: 1,
            symbol: "arrow.triangle.2.circlepath",
            title: String(localized: "Eksikler listeye düşsün"),
            description: String(localized: "Biten ürünler otomatik eklenir. Azalanları marketten önce tek dokunuşla listeye taşı."),
            tint: .orange
        ),
        Page(
            id: 2,
            symbol: "checkmark.circle.fill",
            title: String(localized: "Markette hız kazan"),
            description: String(localized: "Alışveriş modunda aldıklarını işaretle; stok ve geçmiş kendiliğinden güncellensin."),
            tint: .green
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Atla", action: onComplete)
                    .foregroundStyle(.secondary)
                    .padding(20)
            }

            TabView(selection: $selection) {
                ForEach(pages) { page in
                    VStack(spacing: 28) {
                        Spacer()
                        Image(systemName: page.symbol)
                            .font(.system(size: 72, weight: .semibold))
                            .foregroundStyle(page.tint)
                            .frame(width: 150, height: 150)
                            .background(page.tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 42))
                            .accessibilityHidden(true)

                        VStack(spacing: 14) {
                            Text(page.title)
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                            Text(page.description)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 30)
                        Spacer()
                    }
                    .tag(page.id)
                    .accessibilityElement(children: .combine)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if selection == pages.count - 1 {
                    onComplete()
                } else {
                    withAnimation(.snappy) { selection += 1 }
                }
            } label: {
                Text(selection == pages.count - 1 ? String(localized: "Başlayalım") : String(localized: "Devam Et"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
            .accessibilityHint(
                selection == pages.count - 1
                    ? String(localized: "Uygulamayı açar")
                    : String(localized: "Sonraki adıma geçer")
            )
        }
        .interactiveDismissDisabled()
    }
}
