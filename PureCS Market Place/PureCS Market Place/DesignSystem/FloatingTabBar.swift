import SwiftUI

/// A floating white tab bar with a raised diamond action button in the middle.
/// Items are split evenly either side of the button.
struct FloatingTabBar<Tab: Hashable>: View {
    let items: [TabBarItem<Tab>]
    @Binding var selection: Tab
    let centerSystemImage: String
    let centerAccessibilityLabel: LocalizedStringKey
    let centerAction: () -> Void

    var body: some View {
        let half = items.count / 2
        HStack(spacing: 0) {
            ForEach(items.prefix(half)) { tabButton(for: $0) }
            centerButton
            ForEach(items.suffix(from: half)) { tabButton(for: $0) }
        }
        .padding(.horizontal, Spacing.s)
        .frame(height: 72)
        .background(Theme.surface, in: Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 20, y: 8)
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, Spacing.xs)
    }

    private func tabButton(for item: TabBarItem<Tab>) -> some View {
        let isSelected = item.tab == selection
        return Button {
            selection = item.tab
        } label: {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .symbolVariant(isSelected ? .fill : .none)
                Text(item.title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Theme.accentText : Theme.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 56)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var centerButton: some View {
        Button(action: centerAction) {
            Image(systemName: centerSystemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.accent)
                        .frame(width: 46, height: 46)
                        .rotationEffect(.degrees(45))
                        .shadow(color: Theme.accent.opacity(0.45), radius: 10, y: 5)
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(centerAccessibilityLabel)
    }
}

#Preview {
    @Previewable @State var selection = 0
    FloatingTabBar(
        items: [
            TabBarItem(tab: 0, title: "Home", systemImage: "house"),
            TabBarItem(tab: 1, title: "Profile", systemImage: "person"),
        ],
        selection: $selection,
        centerSystemImage: "plus",
        centerAccessibilityLabel: "New listing",
    ) {}
    .frame(maxHeight: .infinity, alignment: .bottom)
    .background(Theme.background)
}
