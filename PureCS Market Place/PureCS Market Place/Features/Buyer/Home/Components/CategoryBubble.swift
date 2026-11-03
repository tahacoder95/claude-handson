import SwiftUI

struct CategoryBubble: View {
    let category: ListingCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                CategoryPlaceholder(category: category, symbolSize: 26)
                    .frame(width: 64, height: 64)
                    .clipShape(.rect(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(isSelected ? Theme.accent : Color.white, lineWidth: isSelected ? 3 : 2)
                    }
                    .shadow(color: Theme.shadowColor, radius: 6, y: 3)
                Text(category.title)
                    .font(.caption.weight(isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Theme.accentText : Theme.ink)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        CategoryBubble(category: .electronics, isSelected: true) {}
        CategoryBubble(category: .home, isSelected: false) {}
    }
    .padding()
}
