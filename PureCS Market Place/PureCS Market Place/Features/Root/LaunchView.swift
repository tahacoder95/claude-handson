import SwiftUI

/// Shown while the stored session is checked.
struct LaunchView: View {
    var body: some View {
        VStack(spacing: Spacing.l) {
            BrandMark(size: 80)
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }
}

#Preview {
    LaunchView()
}
