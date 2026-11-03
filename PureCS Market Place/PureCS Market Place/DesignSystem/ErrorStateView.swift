import SwiftUI

/// Full-area error with a retry button, for content that failed to load.
struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't load", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.compactPill)
        }
    }
}

#Preview {
    ErrorStateView(message: "Can't reach the server. Check your connection and the server address.") {}
}
