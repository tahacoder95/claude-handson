import SwiftUI

/// Swipeable hero photos with rounded bottom corners and a thumbnail rail when there's more than one.
struct PhotoGallery: View {
    let photos: [ListingPhoto]
    let category: ListingCategory

    @State private var selectedIndex = 0

    var body: some View {
        TabView(selection: $selectedIndex) {
            if photos.isEmpty {
                ListingImageView(url: nil, category: category, symbolSize: 96)
                    .tag(0)
            } else {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    ListingImageView(url: photo.url, category: category, symbolSize: 96)
                        .tag(index)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .always : .never))
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: Theme.heroRadius, bottomTrailingRadius: Theme.heroRadius))
        .overlay(alignment: .leading) {
            if photos.count > 1 { thumbnailRail }
        }
    }

    private var thumbnailRail: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                Button {
                    withAnimation { selectedIndex = index }
                } label: {
                    ListingImageView(url: photo.url, category: category, symbolSize: 14)
                        .frame(width: 40, height: 40)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(index == selectedIndex ? Theme.accent : Color.clear, lineWidth: 2)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Photo \(index + 1) of \(photos.count)")
            }
        }
        .padding(6)
        .background(.regularMaterial, in: Capsule())
        .padding(.leading, Spacing.m)
    }
}

#Preview {
    PhotoGallery(photos: [], category: .electronics)
        .frame(height: 400)
}
