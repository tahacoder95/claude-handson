import SwiftUI

struct StatCard: View {
    let value: String
    let label: LocalizedStringKey
    let systemImage: String
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isHighlighted ? Color.white : Theme.accentText)
                .frame(width: 30, height: 30)
                .background(isHighlighted ? Color.white.opacity(0.2) : Theme.accentSoft, in: Circle())
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .opacity(0.8)
        }
        .foregroundStyle(isHighlighted ? Color.white : Theme.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s)
        .background(isHighlighted ? Theme.accent : Theme.surface, in: RoundedRectangle(cornerRadius: Theme.fieldRadius))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HStack {
        StatCard(value: "3", label: "Active", systemImage: "tag", isHighlighted: false)
        StatCard(value: "AED 1,150", label: "Earned", systemImage: "banknote", isHighlighted: true)
    }
    .padding()
    .background(Theme.background)
}
