import PhotosUI
import SwiftUI

/// Add-photo tile plus the current photos (already uploaded and newly picked), each removable.
struct PhotoPickerStrip: View {
    let existingPhotos: [ListingPhoto]
    let newPhotos: [PhotoAttachment]
    let category: ListingCategory
    let remainingSlots: Int
    let isProcessing: Bool
    @Binding var pickerItems: [PhotosPickerItem]
    let onRemoveExisting: (ListingPhoto) -> Void
    let onRemoveNew: (PhotoAttachment) -> Void

    private static let tileSize: CGFloat = 96

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Photos")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s) {
                    if remainingSlots > 0 {
                        addTile
                    }
                    ForEach(Array(existingPhotos.enumerated()), id: \.element.id) { index, photo in
                        PhotoTile(size: Self.tileSize, isCover: index == 0, onRemove: { onRemoveExisting(photo) }) {
                            ListingImageView(url: photo.url, category: category, symbolSize: 22)
                        }
                    }
                    ForEach(Array(newPhotos.enumerated()), id: \.element.id) { index, attachment in
                        PhotoTile(size: Self.tileSize, isCover: existingPhotos.isEmpty && index == 0, onRemove: { onRemoveNew(attachment) }) {
                            LocalPhotoView(data: attachment.data)
                        }
                    }
                }
                // Room for the remove buttons that overhang each tile.
                .padding(.vertical, Spacing.xs)
                .padding(.trailing, Spacing.xs)
            }
            Text("Up to \(ListingDraft.maxPhotos) photos. The first one is the cover.")
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var addTile: some View {
        PhotosPicker(selection: $pickerItems, maxSelectionCount: remainingSlots, matching: .images) {
            VStack(spacing: Spacing.xxs) {
                if isProcessing {
                    ProgressView()
                } else {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                }
                Text("Add photo")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(Theme.accentText)
            .frame(width: Self.tileSize, height: Self.tileSize)
            .background(Theme.accentSoft, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Theme.accent.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            }
        }
        .disabled(isProcessing)
    }
}

#Preview {
    @Previewable @State var items: [PhotosPickerItem] = []
    PhotoPickerStrip(
        existingPhotos: [],
        newPhotos: [],
        category: .home,
        remainingSlots: 3,
        isProcessing: false,
        pickerItems: $items,
        onRemoveExisting: { _ in },
        onRemoveNew: { _ in },
    )
    .padding()
    .background(Theme.background)
}
