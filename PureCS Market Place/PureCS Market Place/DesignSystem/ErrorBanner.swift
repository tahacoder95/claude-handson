import SwiftUI

/// An inline error message, e.g. a failed sign-in.
struct ErrorBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.danger)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.m)
            .background(Theme.dangerSoft, in: RoundedRectangle(cornerRadius: Theme.fieldRadius))
    }
}

#Preview {
    ErrorBanner(message: "Wrong username or password.")
        .padding()
}
