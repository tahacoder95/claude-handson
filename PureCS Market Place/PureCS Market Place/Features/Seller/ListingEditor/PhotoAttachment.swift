import Foundation

/// A newly picked, already-compressed photo that hasn't been uploaded yet.
struct PhotoAttachment: Identifiable, Equatable {
    let id = UUID()
    let data: Data
}
