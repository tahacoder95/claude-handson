import Foundation

/// One source of truth for async screen content, so loading/error/data can't disagree.
enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(message: String)

    var value: Value? {
        if case .loaded(let value) = self { value } else { nil }
    }
}

extension Loadable: Equatable where Value: Equatable {}
