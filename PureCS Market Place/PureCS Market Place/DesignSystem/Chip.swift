import SwiftUI

/// A small capsule label, e.g. an item's condition.
struct Chip: View {
    enum Style {
        case frosted
        case accent
        case neutral
        case success
    }

    let text: String
    var style: Style = .neutral

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
    }

    private var foreground: Color {
        switch style {
        case .frosted, .neutral: Theme.ink
        case .accent: Theme.accentText
        case .success: Theme.success
        }
    }

    private var background: AnyShapeStyle {
        switch style {
        case .frosted: AnyShapeStyle(.ultraThinMaterial)
        case .accent: AnyShapeStyle(Theme.accentSoft)
        case .neutral: AnyShapeStyle(Theme.surfaceMuted)
        case .success: AnyShapeStyle(Theme.success.opacity(0.12))
        }
    }
}

#Preview {
    HStack {
        Chip(text: "Like New", style: .accent)
        Chip(text: "Electronics")
        Chip(text: "Sold", style: .success)
    }
    .padding()
}
