import Foundation
import MacroMonstersCore

protocol FoodSearchProviding {
    func search(query: String) async throws -> [FoodSearchResult]
}

enum FoodSearchServiceFactory {
    static func makeDefault() -> FoodSearchProviding {
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            return LocalFoodSearchProvider()
        }

        let rawAPIKey = Bundle.main.object(forInfoDictionaryKey: "FDC_API_KEY") as? String
        let apiKey = rawAPIKey.flatMap { value -> String? in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty || trimmed.contains("$(") ? nil : trimmed
        }

        if let apiKey {
            return FoodDataCentralClient(apiKey: apiKey)
        }
        return LocalFoodSearchProvider()
    }
}

struct FoodDataCentralClient: FoodSearchProviding {
    var apiKey: String
    var session: URLSession = .shared

    func search(query: String) async throws -> [FoodSearchResult] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/foods/search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: trimmedQuery),
            URLQueryItem(name: "pageSize", value: "20"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        guard let url = components?.url else {
            throw FoodSearchError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw FoodSearchError.requestFailed
        }

        let decoded = try JSONDecoder().decode(FoodDataCentralResponse.self, from: data)
        return decoded.foods.map(\.result)
    }
}

enum FoodSearchError: LocalizedError {
    case invalidURL
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The food search URL could not be built."
        case .requestFailed:
            return "Food search failed. Try manual entry or search again."
        }
    }
}

private struct FoodDataCentralResponse: Decodable {
    var foods: [FoodDataCentralFood]
}

private struct FoodDataCentralFood: Decodable {
    var fdcId: Int
    var description: String
    var brandOwner: String?
    var servingSize: Double?
    var servingSizeUnit: String?
    var foodNutrients: [FoodDataCentralNutrient]

    var result: FoodSearchResult {
        FoodSearchResult(
            id: "fdc-\(fdcId)",
            name: description.capitalized,
            brand: brandOwner,
            servingDescription: servingDescription,
            macrosPerServing: MacroNutrients(
                calories: nutrientValue(named: ["Energy"]),
                proteinGrams: nutrientValue(named: ["Protein"]),
                carbGrams: nutrientValue(named: ["Carbohydrate, by difference", "Carbohydrate, by summation"]),
                fatGrams: nutrientValue(named: ["Total lipid (fat)", "Total Fat"])
            )
        )
    }

    private var servingDescription: String {
        if let servingSize, let servingSizeUnit, servingSize > 0 {
            return "\(servingSize.formatted(.number.precision(.fractionLength(0...1)))) \(servingSizeUnit)"
        }
        return "100 g"
    }

    private func nutrientValue(named acceptedNames: [String]) -> Double {
        foodNutrients.first { nutrient in
            acceptedNames.contains { accepted in
                nutrient.nutrientName.localizedCaseInsensitiveContains(accepted)
            }
        }?.value ?? 0
    }
}

private struct FoodDataCentralNutrient: Decodable {
    var nutrientName: String
    var value: Double?
}

struct LocalFoodSearchProvider: FoodSearchProviding {
    private let foods: [FoodSearchResult] = [
        FoodSearchResult(
            id: "local-greek-yogurt",
            name: "Greek Yogurt",
            brand: "Sample",
            servingDescription: "170 g",
            macrosPerServing: MacroNutrients(calories: 100, proteinGrams: 17, carbGrams: 6, fatGrams: 0)
        ),
        FoodSearchResult(
            id: "local-rice",
            name: "Cooked Rice",
            brand: "Sample",
            servingDescription: "1 cup",
            macrosPerServing: MacroNutrients(calories: 205, proteinGrams: 4, carbGrams: 45, fatGrams: 0)
        ),
        FoodSearchResult(
            id: "local-salmon",
            name: "Salmon",
            brand: "Sample",
            servingDescription: "4 oz",
            macrosPerServing: MacroNutrients(calories: 233, proteinGrams: 25, carbGrams: 0, fatGrams: 14)
        ),
        FoodSearchResult(
            id: "local-avocado",
            name: "Avocado",
            brand: "Sample",
            servingDescription: "1 medium",
            macrosPerServing: MacroNutrients(calories: 240, proteinGrams: 3, carbGrams: 13, fatGrams: 22)
        )
    ]

    func search(query: String) async throws -> [FoodSearchResult] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return foods
        }
        return foods.filter { food in
            food.name.localizedCaseInsensitiveContains(trimmedQuery) ||
            (food.brand?.localizedCaseInsensitiveContains(trimmedQuery) ?? false)
        }
    }
}
