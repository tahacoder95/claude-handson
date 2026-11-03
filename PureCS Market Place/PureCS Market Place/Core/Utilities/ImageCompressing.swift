import Foundation

/// Turns picked photo data into upload-ready JPEG data.
protocol ImageCompressing {
    /// Returns nil when `data` isn't a readable image.
    func jpegData(from data: Data) -> Data?
}
