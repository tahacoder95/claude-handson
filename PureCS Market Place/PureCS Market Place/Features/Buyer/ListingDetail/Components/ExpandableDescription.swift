import SwiftUI

/// "Description" with a Read more toggle for long text.
struct ExpandableDescription: View {
    let text: String

    @State private var isExpanded = false

    private static let collapsedLineLimit = 4
    private static let longTextThreshold = 180

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Description")
                .font(.headline)
                .foregroundStyle(Theme.ink)
            Text(text.isEmpty ? String(localized: "The seller didn't add a description.") : text)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(isExpanded ? nil : Self.collapsedLineLimit)
                .lineSpacing(3)
            if text.count > Self.longTextThreshold {
                Button(isExpanded ? "Show less" : "Read more") {
                    withAnimation(.smooth) { isExpanded.toggle() }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.accentText)
            }
        }
    }
}

#Preview {
    ExpandableDescription(text: SampleData.listings()[0].details)
        .padding()
}
