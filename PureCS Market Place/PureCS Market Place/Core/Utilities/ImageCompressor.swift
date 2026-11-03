import UIKit

/// Downscales to `maxDimension` and re-encodes as JPEG so uploads stay well under the server's 5 MB limit.
final class ImageCompressor: ImageCompressing {
    private let maxDimension: CGFloat
    private let quality: CGFloat

    init(maxDimension: CGFloat = 1600, quality: CGFloat = 0.75) {
        self.maxDimension = maxDimension
        self.quality = quality
    }

    func jpegData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let longestSide = max(image.size.width, image.size.height)
        let scale = min(1, maxDimension / longestSide)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
