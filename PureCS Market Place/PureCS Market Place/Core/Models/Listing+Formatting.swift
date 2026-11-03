import Foundation

extension Listing {
    var formattedPrice: String { price.aedFormatted }

    var postedAgo: String {
        createdAt.formatted(.relative(presentation: .named))
    }

    /// "Dubai Marina, Dubai" → "Dubai Marina".
    var shortLocation: String {
        location.split(separator: ",").first.map { String($0).trimmed } ?? location
    }

    /// A `tel:` URL for the seller's phone, if the listing has one.
    var phoneURL: URL? {
        guard let sellerPhone else { return nil }
        let dialable = sellerPhone.filter { $0.isNumber || $0 == "+" }
        return URL(string: "tel:\(dialable)")
    }
}
