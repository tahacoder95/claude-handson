import Foundation

enum AuthMode: Equatable {
    case signIn
    case register

    var toggled: AuthMode { self == .signIn ? .register : .signIn }
}
