import Foundation

/// Builds a `multipart/form-data` body for photo uploads.
struct MultipartFormData {
    private let boundary = "Boundary-\(UUID().uuidString)"
    private var body = Data()

    var contentType: String { "multipart/form-data; boundary=\(boundary)" }

    mutating func addField(_ name: String, value: String) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        append("\(value)\r\n")
    }

    mutating func addFile(_ name: String, fileName: String, mimeType: String, data: Data) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        append("\r\n")
    }

    func encoded() -> Data {
        var data = body
        data.append(Data("--\(boundary)--\r\n".utf8))
        return data
    }

    private mutating func append(_ string: String) {
        body.append(Data(string.utf8))
    }
}

extension MultipartFormData {
    /// The listing fields and new photos, as the API's create and update endpoints expect them.
    static func listing(_ input: ListingInput) -> MultipartFormData {
        var form = MultipartFormData()
        form.addField("title", value: input.title)
        form.addField("description", value: input.details)
        form.addField("price_aed", value: NSDecimalNumber(decimal: input.price).stringValue)
        form.addField("category", value: input.category.rawValue)
        form.addField("condition", value: input.condition.rawValue)
        form.addField("location", value: input.location)
        for (index, photo) in input.newPhotos.enumerated() {
            form.addFile("photos", fileName: "photo-\(index + 1).jpg", mimeType: "image/jpeg", data: photo)
        }
        return form
    }
}
