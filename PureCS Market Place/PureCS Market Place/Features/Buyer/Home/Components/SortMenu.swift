import SwiftUI

/// The round filter button beside the search field.
struct SortMenu: View {
    let selection: ListingSort
    let onSelect: (ListingSort) -> Void

    var body: some View {
        Menu {
            Picker("Sort by", selection: Binding(get: { selection }, set: onSelect)) {
                ForEach(ListingSort.allCases) { sort in
                    Text(sort.title).tag(sort)
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .frame(width: 52, height: 52)
                .background(Theme.surface, in: Circle())
                .shadow(color: Theme.shadowColor, radius: 10, y: 4)
        }
        .accessibilityLabel("Sort listings")
        .accessibilityValue(selection.title)
    }
}

#Preview {
    SortMenu(selection: .newest) { _ in }
        .padding()
        .background(Theme.background)
}
