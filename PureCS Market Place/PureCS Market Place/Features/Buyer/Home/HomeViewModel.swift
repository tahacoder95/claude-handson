import Foundation
import Observation

@Observable
final class HomeViewModel {
    private(set) var state: Loadable<[Listing]> = .idle
    var searchText = ""
    private(set) var selectedCategory: ListingCategory?
    private(set) var sort: ListingSort = .newest

    private let repository: any ListingBrowsing

    init(repository: any ListingBrowsing) {
        self.repository = repository
    }

    // MARK: - State

    var sectionTitle: String {
        let term = searchText.trimmed
        if !term.isEmpty { return String(localized: "Results for “\(term)”") }
        if let selectedCategory { return selectedCategory.title }
        return String(localized: "Latest listings")
    }

    var hasActiveFilters: Bool {
        selectedCategory != nil || !searchText.trimmed.isEmpty
    }

    /// The promo makes sense on the unfiltered feed only.
    var showsPromo: Bool { !hasActiveFilters }

    // MARK: - Intents

    func load() async {
        // Keep showing current results while refreshing instead of flashing a spinner.
        if state.value == nil { state = .loading }
        do {
            state = .loaded(try await repository.fetchListings(matching: query))
        } catch is CancellationError {
            return
        } catch {
            state = .failed(message: error.userMessage)
        }
    }

    /// Debounces typing; a newer keystroke cancels the pending search.
    func searchTextChanged() async {
        if case .idle = state {
            await load()
            return
        }
        do {
            try await Task.sleep(for: .milliseconds(300))
        } catch {
            return
        }
        await load()
    }

    func selectCategory(_ category: ListingCategory?) async {
        guard category != selectedCategory else { return }
        selectedCategory = category
        await load()
    }

    func selectSort(_ newSort: ListingSort) async {
        guard newSort != sort else { return }
        sort = newSort
        await load()
    }

    func clearFilters() async {
        searchText = ""
        selectedCategory = nil
        await load()
    }

    // MARK: - Private

    private var query: ListingQuery {
        ListingQuery(text: searchText.trimmed, category: selectedCategory, sort: sort)
    }
}
