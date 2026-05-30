import MacroMonstersCore
@testable import MacroMonstersFoodSearch
import XCTest

final class FoodSearchTests: XCTestCase {
    func testLocalProviderReturnsSampleFoodsForEmptySearch() async throws {
        let provider = LocalFoodSearchProvider()

        let results = try await provider.search(query: "   ")

        XCTAssertEqual(provider.searchMode, .sampleFoods)
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.contains { $0.name == "Greek Yogurt" })
    }

    func testLocalProviderFiltersByQuery() async throws {
        let provider = LocalFoodSearchProvider()

        let results = try await provider.search(query: "rice")

        XCTAssertEqual(results.map(\.name), ["Cooked Rice"])
    }

    @MainActor
    func testViewModelReportsLoadingThenSuccess() async {
        let provider = DelayedFoodSearchProvider(results: [.sample(name: "Chicken Bowl")])
        let viewModel = FoodSearchViewModel(provider: provider)

        let searchTask = Task {
            await viewModel.search()
        }
        await Task.yield()

        XCTAssertEqual(viewModel.state, .loading)

        await searchTask.value

        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.results.map(\.name), ["Chicken Bowl"])
    }

    @MainActor
    func testViewModelReportsEmptyResults() async {
        let viewModel = FoodSearchViewModel(provider: StubFoodSearchProvider(results: []))

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertTrue(viewModel.results.isEmpty)
    }

    @MainActor
    func testViewModelReportsErrorWithoutClearingPreviousResults() async {
        let provider = MutableFoodSearchProvider(results: [.sample(name: "Greek Yogurt")])
        let viewModel = FoodSearchViewModel(provider: provider)

        await viewModel.search()
        provider.error = FoodSearchError.requestFailed
        await viewModel.search()

        XCTAssertEqual(viewModel.state, .error("Food search failed. Try manual entry or search again."))
        XCTAssertEqual(viewModel.results.map(\.name), ["Greek Yogurt"])
    }
}

private final class StubFoodSearchProvider: FoodSearchProviding {
    var searchMode: FoodSearchMode = .sampleFoods
    var results: [FoodSearchResult]

    init(results: [FoodSearchResult]) {
        self.results = results
    }

    func search(query: String) async throws -> [FoodSearchResult] {
        results
    }
}

private final class MutableFoodSearchProvider: FoodSearchProviding {
    var searchMode: FoodSearchMode = .sampleFoods
    var results: [FoodSearchResult]
    var error: Error?

    init(results: [FoodSearchResult]) {
        self.results = results
    }

    func search(query: String) async throws -> [FoodSearchResult] {
        if let error {
            throw error
        }
        return results
    }
}

private final class DelayedFoodSearchProvider: FoodSearchProviding {
    var searchMode: FoodSearchMode = .sampleFoods
    var results: [FoodSearchResult]

    init(results: [FoodSearchResult]) {
        self.results = results
    }

    func search(query: String) async throws -> [FoodSearchResult] {
        try await Task.sleep(nanoseconds: 100_000_000)
        return results
    }
}

private extension FoodSearchResult {
    static func sample(name: String) -> FoodSearchResult {
        FoodSearchResult(
            id: "test-\(name)",
            name: name,
            servingDescription: "1 serving",
            macrosPerServing: MacroNutrients(calories: 100, proteinGrams: 10, carbGrams: 10, fatGrams: 4)
        )
    }
}
