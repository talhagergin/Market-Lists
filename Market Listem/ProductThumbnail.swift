import SwiftUI

struct ProductThumbnail: View {
    let name: String
    let category: ProductCategory
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30)
                .fill(.green.opacity(0.10))

            if let assetName = ProductCatalog.assetName(for: name) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.08)
            } else {
                Image(systemName: ProductCatalog.symbol(for: name, category: category))
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.green)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
