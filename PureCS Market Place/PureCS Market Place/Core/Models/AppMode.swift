import Foundation

/// One account, two experiences.
enum AppMode: Equatable {
    case buying
    case selling

    var toggled: AppMode { self == .buying ? .selling : .buying }
}
