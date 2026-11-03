import SwiftUI

/// "Categories ··········· See all"
struct SectionHeader: View {
    let title: String
    var actionTitle: LocalizedStringKey?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.ink)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.accentText)
            }
        }
    }
}

#Preview {
    SectionHeader(title: "Categories", actionTitle: "Show all") {}
        .padding()
}
