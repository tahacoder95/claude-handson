import Foundation

extension Endpoint {
    static func listings(_ query: ListingQuery) -> Endpoint {
        var items = [URLQueryItem(name: "sort", value: query.sort.rawValue)]
        if !query.text.isEmpty {
            items.append(URLQueryItem(name: "q", value: query.text))
        }
        if let category = query.category {
            items.append(URLQueryItem(name: "category", value: category.rawValue))
        }
        return Endpoint(path: "/listings", queryItems: items)
    }

    static func listing(id: Listing.ID) -> Endpoint {
        Endpoint(path: "/listings/\(id)")
    }

    static let myListings = Endpoint(path: "/me/listings")

    static func createListing(_ input: ListingInput) -> Endpoint {
        let form = MultipartFormData.listing(input)
        return Endpoint(method: .post, path: "/listings", body: form.encoded(), contentType: form.contentType)
    }

    static func updateListing(id: Listing.ID, with input: ListingInput) -> Endpoint {
        var form = MultipartFormData.listing(input)
        if !input.removedPhotoIDs.isEmpty {
            form.addField("remove_photo_ids", value: input.removedPhotoIDs.map(String.init).joined(separator: ","))
        }
        return Endpoint(method: .patch, path: "/listings/\(id)", body: form.encoded(), contentType: form.contentType)
    }

    static func updateStatus(_ status: ListingStatus, forListing id: Listing.ID) throws -> Endpoint {
        try .json(.patch, "/listings/\(id)", body: UpdateStatusRequest(status: status.rawValue))
    }

    static func deleteListing(id: Listing.ID) -> Endpoint {
        Endpoint(method: .delete, path: "/listings/\(id)")
    }
}
