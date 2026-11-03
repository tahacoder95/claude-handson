import SwiftUI
import UIKit

/// Shows a picked photo that hasn't been uploaded yet.
struct LocalPhotoView: View {
    let data: Data

    var body: some View {
        Color.clear
            .overlay {
                if let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Theme.surfaceMuted
                }
            }
            .clipped()
    }
}

#Preview {
    LocalPhotoView(data: Data())
        .frame(width: 96, height: 96)
}
