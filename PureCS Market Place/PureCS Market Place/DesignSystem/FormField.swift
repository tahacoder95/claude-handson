import SwiftUI

/// A label above a white rounded input, with an optional validation message below.
struct FormField<Content: View>: View {
    let label: LocalizedStringKey
    var message: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
            content
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.fieldRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.fieldRadius)
                        .strokeBorder(message == nil ? Color.clear : Theme.danger, lineWidth: 1.5)
                }
            if let message {
                Label(message, systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(Theme.danger)
            }
        }
    }
}

#Preview {
    @Previewable @State var title = ""
    VStack(spacing: Spacing.l) {
        FormField(label: "Title") {
            TextField("What are you selling?", text: $title)
        }
        FormField(label: "Price", message: "Enter a price above 0.") {
            TextField("0", text: $title)
        }
    }
    .padding()
    .background(Theme.background)
}
