import Foundation

/// The numbers at the top of My Listings.
struct SellerStats: Equatable {
    let activeCount: Int
    let soldCount: Int
    /// Sum of sold listings' prices.
    let earned: Decimal

    init(listings: [Listing]) {
        let sold = listings.filter { $0.status == .sold }
        activeCount = listings.count - sold.count
        soldCount = sold.count
        earned = sold.reduce(Decimal.zero) { $0 + $1.price }
    }
}
