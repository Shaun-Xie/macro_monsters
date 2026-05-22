import Foundation
import MacroMonstersCore

@MainActor
final class FoodSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [FoodSearchResult] = []
    @Published private(set) var isSearching = false
    @Published var errorMessage: String?

    private let provider: FoodSearchProviding

    init(provider: FoodSearchProviding = FoodSearchServiceFactory.makeDefault()) {
        self.provider = provider
    }

    func search() async {
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            results = try await provider.search(query: query)
        } catch {
            results = []
            errorMessage = error.localizedDescription
        }
    }
}
