import SwiftUI

/// A square photo thumbnail with a remove button and an optional "Cover" badge.
struct PhotoTile<Content: View>: View {
    let size: CGFloat
    let isCover: Bool
    let onRemove: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(width: size, height: size)
            .clipShape(.rect(cornerRadius: 18))
            .overlay(alignment: .bottomLeading) {
                if isCover {
                    Text("Cover")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.6), in: Capsule())
                        .padding(6)
                }
            }
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Theme.ink, in: Circle())
                        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .offset(x: 8, y: -8)
                .accessibilityLabel("Remove photo")
            }
    }
}

#Preview {
    PhotoTile(size: 96, isCover: true, onRemove: {}) {
        CategoryPlaceholder(category: .sports, symbolSize: 22)
    }
    .padding()
}
