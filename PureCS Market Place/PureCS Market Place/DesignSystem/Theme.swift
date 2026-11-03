import SwiftUI

/// Soft periwinkle palette: pale lavender background, white cards, pill buttons, circular controls.
enum Theme {
    // MARK: - Colours

    static let accent = Color(hex: 0x6B73E8)
    static let accentPressed = Color(hex: 0x5961D9)
    /// Accent for text on light backgrounds (meets 4.5:1 contrast).
    static let accentText = Color(hex: 0x4A52C9)
    static let accentSoft = Color(hex: 0xE8EAFD)

    static let background = Color(hex: 0xF4F5FB)
    static let surface = Color.white
    static let surfaceMuted = Color(hex: 0xECEDF6)

    static let ink = Color(hex: 0x1C1D2B)
    static let textSecondary = Color(hex: 0x666879)

    static let danger = Color(hex: 0xC62F25)
    static let dangerSoft = Color(hex: 0xFCE9E7)
    static let success = Color(hex: 0x1F8A55)

    static let promoGradient = LinearGradient(
        colors: [Color(hex: 0xE4E7FD), Color(hex: 0xD4EEF4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing,
    )

    // MARK: - Shapes and shadows

    static let cardRadius: CGFloat = 22
    static let fieldRadius: CGFloat = 18
    static let heroRadius: CGFloat = 36
    static let shadowColor = Color.black.opacity(0.07)
}
