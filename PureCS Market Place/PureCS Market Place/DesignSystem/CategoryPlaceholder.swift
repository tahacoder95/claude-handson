import SwiftUI

/// Pastel gradient with the category's symbol, shown when there's no photo.
struct CategoryPlaceholder: View {
    let category: ListingCategory
    var symbolSize: CGFloat = 44

    var body: some View {
        LinearGradient(colors: category.placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Image(systemName: category.symbolName)
                    .font(.system(size: symbolSize, weight: .regular))
                    .foregroundStyle(category.symbolColor.opacity(0.85))
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        ForEach(ListingCategory.allCases) { category in
            CategoryPlaceholder(category: category, symbolSize: 20)
                .frame(width: 44, height: 44)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
    .padding()
}
