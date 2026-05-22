import Foundation

public struct MacroNutrients: Codable, Equatable, Sendable {
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double

    public init(
        calories: Double = 0,
        proteinGrams: Double = 0,
        carbGrams: Double = 0,
        fatGrams: Double = 0
    ) {
        self.calories = max(0, calories)
        self.proteinGrams = max(0, proteinGrams)
        self.carbGrams = max(0, carbGrams)
        self.fatGrams = max(0, fatGrams)
    }

    public static let zero = MacroNutrients()

    public func scaled(by multiplier: Double) -> MacroNutrients {
        let safeMultiplier = max(0, multiplier)
        return MacroNutrients(
            calories: calories * safeMultiplier,
            proteinGrams: proteinGrams * safeMultiplier,
            carbGrams: carbGrams * safeMultiplier,
            fatGrams: fatGrams * safeMultiplier
        )
    }

    public func roundedForDisplay() -> MacroNutrients {
        MacroNutrients(
            calories: calories.rounded(),
            proteinGrams: proteinGrams.rounded(),
            carbGrams: carbGrams.rounded(),
            fatGrams: fatGrams.rounded()
        )
    }

    public static func + (lhs: MacroNutrients, rhs: MacroNutrients) -> MacroNutrients {
        MacroNutrients(
            calories: lhs.calories + rhs.calories,
            proteinGrams: lhs.proteinGrams + rhs.proteinGrams,
            carbGrams: lhs.carbGrams + rhs.carbGrams,
            fatGrams: lhs.fatGrams + rhs.fatGrams
        )
    }

    public mutating func add(_ other: MacroNutrients) {
        self = self + other
    }
}

public struct DailyGoals: Codable, Equatable, Sendable {
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double

    public init(
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double
    ) {
        self.calories = max(0, calories)
        self.proteinGrams = max(0, proteinGrams)
        self.carbGrams = max(0, carbGrams)
        self.fatGrams = max(0, fatGrams)
    }

    public var targetMacros: MacroNutrients {
        MacroNutrients(
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams
        )
    }
}

public struct FoodItem: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var brand: String?
    public var servingDescription: String
    public var macrosPerServing: MacroNutrients

    public init(
        id: String = UUID().uuidString,
        name: String,
        brand: String? = nil,
        servingDescription: String,
        macrosPerServing: MacroNutrients
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.servingDescription = servingDescription
        self.macrosPerServing = macrosPerServing
    }
}

public struct FoodSearchResult: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var brand: String?
    public var servingDescription: String
    public var macrosPerServing: MacroNutrients

    public init(
        id: String,
        name: String,
        brand: String? = nil,
        servingDescription: String,
        macrosPerServing: MacroNutrients
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.servingDescription = servingDescription
        self.macrosPerServing = macrosPerServing
    }

    public var foodItem: FoodItem {
        FoodItem(
            id: id,
            name: name,
            brand: brand,
            servingDescription: servingDescription,
            macrosPerServing: macrosPerServing
        )
    }
}

public struct FoodLogEntry: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var food: FoodItem
    public var servingMultiplier: Double
    public var loggedAt: Date

    public init(
        id: UUID = UUID(),
        food: FoodItem,
        servingMultiplier: Double = 1,
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.food = food
        self.servingMultiplier = max(0, servingMultiplier)
        self.loggedAt = loggedAt
    }

    public var macros: MacroNutrients {
        food.macrosPerServing.scaled(by: servingMultiplier)
    }
}

public struct DailySummary: Codable, Equatable, Sendable {
    public var date: Date
    public var totals: MacroNutrients
    public var logCount: Int

    public init(date: Date, totals: MacroNutrients = .zero, logCount: Int = 0) {
        self.date = date
        self.totals = totals
        self.logCount = max(0, logCount)
    }
}

public enum NutritionCalculator {
    public static func totals(from logs: [FoodLogEntry]) -> MacroNutrients {
        logs.reduce(into: MacroNutrients.zero) { partial, log in
            partial.add(log.macros)
        }
    }

    public static func summary(
        for date: Date,
        logs: [FoodLogEntry],
        calendar: Calendar = .current
    ) -> DailySummary {
        let matchingLogs = logs.filter { calendar.isDate($0.loggedAt, inSameDayAs: date) }
        return DailySummary(
            date: calendar.startOfDay(for: date),
            totals: totals(from: matchingLogs),
            logCount: matchingLogs.count
        )
    }
}
