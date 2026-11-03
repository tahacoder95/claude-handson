import Foundation

/// The same demo accounts and listings as `backend/scripts/seed.js`.
enum SampleData {
    static let password = "demo123"

    static let omar = User(id: 1, username: "omar", displayName: "Omar Haddad", phone: "+971 50 987 6543")
    static let aisha = User(id: 2, username: "aisha", displayName: "Aisha Khan", phone: "+971 50 123 4567")
    static let sara = User(id: 3, username: "sara", displayName: "Sara Ali", phone: "+971 55 234 5678")
    static let ravi = User(id: 4, username: "ravi", displayName: "Ravi Menon", phone: "+971 52 345 6789")

    static let users = [omar, aisha, sara, ravi]

    static func listings(now: Date = .now) -> [Listing] {
        var nextID = 1
        func listing(
            _ seller: User,
            _ title: String,
            _ details: String,
            _ price: Decimal,
            _ category: ListingCategory,
            _ condition: ItemCondition,
            _ location: String,
            daysAgo: Double,
            status: ListingStatus = .active,
        ) -> Listing {
            defer { nextID += 1 }
            return Listing(
                id: nextID,
                sellerID: seller.id,
                sellerName: seller.displayName,
                sellerPhone: seller.phone,
                title: title,
                details: details,
                price: price,
                category: category,
                condition: condition,
                location: location,
                photos: [],
                status: status,
                createdAt: now.addingTimeInterval(-daysAgo * 86_400),
            )
        }

        return [
            listing(aisha, "iPhone 14 · 128GB, Midnight", "Used for eight months, always in a case with a screen protector. Battery health 91%. Comes with the original box and cable. No scratches or dents.", 1950, .electronics, .likeNew, "Dubai Marina, Dubai", daysAgo: 2),
            listing(aisha, "Nespresso Vertuo coffee machine", "Works perfectly, descaled last month. Includes the milk frother and a sleeve of pods.", 380, .home, .likeNew, "Dubai Marina, Dubai", daysAgo: 6),
            listing(aisha, "Yoga mat and resistance bands", "Brand new 6 mm mat plus a set of five resistance bands. Never used, still in the bag.", 95, .sports, .new, "Dubai Marina, Dubai", daysAgo: 8),
            listing(sara, "IKEA 3-seat sofa, grey", "Comfortable KIVIK sofa with washable covers. Pet-free and smoke-free home. You collect.", 900, .home, .good, "Al Majaz, Sharjah", daysAgo: 3),
            listing(sara, "Wool coat, size M", "Camel wool-blend coat, worn twice. Perfect for travel to colder places.", 220, .fashion, .likeNew, "Al Majaz, Sharjah", daysAgo: 4),
            listing(sara, "Bundle of 6 paperbacks", "Mix of fiction and self-help, all in good condition. Happy to list the titles on request.", 120, .books, .good, "Al Majaz, Sharjah", daysAgo: 6),
            listing(sara, "Nike Air Jordan 1, size 42", "Unworn, original box and receipt. Bought the wrong size.", 650, .fashion, .new, "Al Majaz, Sharjah", daysAgo: 1),
            listing(ravi, "Toyota Corolla 2019, 62,000 km", "Single owner, full service history at the agency. GCC specs, no accidents.", 48500, .vehicles, .good, "Al Barsha, Dubai", daysAgo: 5),
            listing(ravi, "Road bike, 54 cm frame", "Aluminium frame, Shimano 105 groupset. New tyres fitted in September.", 1400, .sports, .good, "Al Barsha, Dubai", daysAgo: 7),
            listing(ravi, "Samsung 55\" 4K smart TV", "Crisp picture, comes with the remote and wall bracket. Moving out sale.", 1100, .electronics, .good, "Al Barsha, Dubai", daysAgo: 3),
            listing(ravi, "Dining table with 4 chairs", "Solid wood, a few marks on the tabletop. Seats four comfortably.", 750, .home, .fair, "Al Barsha, Dubai", daysAgo: 10),
            listing(omar, "Trek Marlin 7 mountain bike", "Size M, hydraulic disc brakes. Serviced last month, ready to ride.", 1850, .sports, .good, "Al Reem Island, Abu Dhabi", daysAgo: 3),
            listing(omar, "PlayStation 5 Slim + 2 controllers", "Disc edition with two DualSense controllers. Selling because I barely play.", 1700, .electronics, .likeNew, "Al Reem Island, Abu Dhabi", daysAgo: 5),
            listing(omar, "Leather office chair", "Ergonomic chair with lumbar support. Adjustable height and arms.", 450, .home, .good, "Al Reem Island, Abu Dhabi", daysAgo: 9),
            listing(omar, "Standing desk, oak top", "Electric sit-stand desk, 140 × 70 cm.", 650, .home, .good, "Al Reem Island, Abu Dhabi", daysAgo: 21, status: .sold),
            listing(omar, "AirPods Pro (2nd gen)", "With charging case and spare tips.", 500, .electronics, .likeNew, "Al Reem Island, Abu Dhabi", daysAgo: 30, status: .sold),
        ]
    }
}
