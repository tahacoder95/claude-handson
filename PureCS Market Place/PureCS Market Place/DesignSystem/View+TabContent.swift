import SwiftUI

extension View {
    /// Keeps a tab's view alive (and its scroll position and state) while another tab is showing.
    func tabContent(isActive: Bool) -> some View {
        opacity(isActive ? 1 : 0)
            .allowsHitTesting(isActive)
            .accessibilityHidden(!isActive)
    }
}
