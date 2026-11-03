import SwiftUI

extension ListingCategory {
    var symbolName: String {
        switch self {
        case .electronics: "iphone.gen3"
        case .home: "sofa"
        case .fashion: "tshirt"
        case .vehicles: "car"
        case .books: "book"
        case .sports: "figure.run"
        case .other: "shippingbox"
        }
    }

    /// Pastel gradient used where a listing has no photo.
    var placeholderColors: [Color] {
        switch self {
        case .electronics: [Color(hex: 0xDCE9FA), Color(hex: 0xBDD6F4)]
        case .home: [Color(hex: 0xFCE8D9), Color(hex: 0xF5D0B2)]
        case .fashion: [Color(hex: 0xFADFE9), Color(hex: 0xF1C3D6)]
        case .vehicles: [Color(hex: 0xE5E3FB), Color(hex: 0xCDC8F3)]
        case .books: [Color(hex: 0xF1E8DA), Color(hex: 0xE2D2BA)]
        case .sports: [Color(hex: 0xDBF2E5), Color(hex: 0xB9E3CB)]
        case .other: [Color(hex: 0xE8EAF0), Color(hex: 0xD3D7E1)]
        }
    }

    var symbolColor: Color {
        switch self {
        case .electronics: Color(hex: 0x2F5BB7)
        case .home: Color(hex: 0xA4561B)
        case .fashion: Color(hex: 0xA1365F)
        case .vehicles: Color(hex: 0x4B43A8)
        case .books: Color(hex: 0x6F4D2C)
        case .sports: Color(hex: 0x2B7341)
        case .other: Color(hex: 0x4A5060)
        }
    }
}
