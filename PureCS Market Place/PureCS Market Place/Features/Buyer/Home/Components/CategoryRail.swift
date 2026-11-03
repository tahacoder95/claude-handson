import SwiftUI

/// "Categories" header and a horizontal row of category bubbles. Tapping the selected one clears it.
struct CategoryRail: View {
    let selection: ListingCategory?
    let onSelect: (ListingCategory?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(
                title: String(localized: "Categories"),
                actionTitle: selection == nil ? nil : "Show all",
                action: { onSelect(nil) },
            )
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Spacing.m) {
                    ForEach(ListingCategory.allCases) { category in
                        CategoryBubble(category: category, isSelected: category == selection) {
                            onSelect(category == selection ? nil : category)
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.xxs)
            }
            .padding(.horizontal, -Spacing.l)
        }
    }
}

#Preview {
    CategoryRail(selection: .home) { _ in }
        .padding()
        .background(Theme.background)
}
