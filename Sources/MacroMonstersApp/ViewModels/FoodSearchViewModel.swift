import Foundation
import MacroMonstersCore

@MainActor
final class FoodSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [FoodSearchResult] = []
    @Published private(set) var state: FoodSearchState = .idle

    private let provider: FoodSearchProviding

    init(provider: FoodSearchProviding = FoodSearchServiceFactory.makeDefault()) {
        self.provider = provider
    }

    var searchMode: FoodSearchMode {
        provider.searchMode
    }

    var isSearching: Bool {
        state == .loading
    }

    var errorMessage: String? {
        if case let .error(message) = state {
            return message
        }
        return nil
    }

    var isEmptyResult: Bool {
        state == .empty
    }

    func search() async {
        state = .loading

        do {
            results = try await provider.search(query: query)
            state = results.isEmpty ? .empty : .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

enum FoodSearchState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
