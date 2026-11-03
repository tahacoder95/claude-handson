import Foundation

extension Decimal {
    /// Whole-dirham price, e.g. "AED 1,950".
    var aedFormatted: String {
        formatted(.currency(code: "AED").precision(.fractionLength(0)))
    }
}
