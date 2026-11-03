import SwiftUI

/// Rounded search field with a magnifier and a clear button.
struct SearchField: View {
    @Binding var text: String
    var prompt: LocalizedStringKey = "Search"

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)
            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .foregroundStyle(Theme.ink)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, Spacing.m)
        .frame(minHeight: 52)
        .background(Theme.surfaceMuted, in: Capsule())
    }
}

#Preview {
    @Previewable @State var text = ""
    SearchField(text: $text, prompt: "Search items")
        .padding()
}
