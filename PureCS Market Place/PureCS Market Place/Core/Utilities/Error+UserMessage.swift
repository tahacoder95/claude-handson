import Foundation

extension Error {
    var userMessage: String {
        (self as? LocalizedError)?.errorDescription
            ?? String(localized: "Something went wrong. Please try again.")
    }
}
