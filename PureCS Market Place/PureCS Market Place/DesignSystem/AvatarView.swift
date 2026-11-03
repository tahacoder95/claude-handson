import SwiftUI

struct AvatarView: View {
    let name: String
    var size: CGFloat = 48

    var body: some View {
        Text(name.initials)
            .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Theme.accent.gradient, in: Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: size > 40 ? 3 : 1.5))
            .shadow(color: Theme.shadowColor, radius: 6, y: 2)
            .accessibilityHidden(true)
    }
}

#Preview {
    AvatarView(name: "Omar Haddad", size: 64)
}
