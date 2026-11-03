import Foundation

struct User: Identifiable, Hashable {
    let id: Int
    var username: String
    var displayName: String
    var phone: String
}
