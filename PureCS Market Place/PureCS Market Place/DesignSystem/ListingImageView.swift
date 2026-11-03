import SwiftUI

/// A listing photo that fills whatever frame it's given, with the category placeholder
/// underneath while loading or when there's no photo. Callers set the frame or aspect ratio.
struct ListingImageView: View {
    let url: URL?
    let category: ListingCategory
    var symbolSize: CGFloat = 44

    var body: some View {
        Color.clear
            .overlay {
                CategoryPlaceholder(category: category, symbolSize: symbolSize)
            }
            .overlay {
                if let url {
                    AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.2))) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        }
                    }
                }
            }
            .clipped()
    }
}

#Preview {
    ListingImageView(url: nil, category: .home)
        .frame(width: 180, height: 220)
        .clipShape(.rect(cornerRadius: Theme.cardRadius))
}
