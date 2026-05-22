import Foundation
import MacroMonstersCore
import SwiftData

@Model
final class UserGoalModel {
    @Attribute(.unique) var id: String
    var calories: Double
    var proteinGrams: Double
    var carbGrams: Double
    var fatGrams: Double
    var updatedAt: Date

    init(
        id: String = "current",
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.updatedAt = updatedAt
    }

    var coreGoals: DailyGoals {
        DailyGoals(
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams
        )
    }
}

@Model
final class FoodLogModel {
    @Attribute(.unique) var id: UUID
    var foodID: String
    var name: String
    var brand: String?
    var servingDescription: String
    var servingMultiplier: Double
    var caloriesPerServing: Double
    var proteinPerServing: Double
    var carbsPerServing: Double
    var fatPerServing: Double
    var loggedAt: Date

    init(
        id: UUID = UUID(),
        item: FoodItem,
        servingMultiplier: Double,
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.foodID = item.id
        self.name = item.name
        self.brand = item.brand
        self.servingDescription = item.servingDescription
        self.servingMultiplier = max(0, servingMultiplier)
        self.caloriesPerServing = item.macrosPerServing.calories
        self.proteinPerServing = item.macrosPerServing.proteinGrams
        self.carbsPerServing = item.macrosPerServing.carbGrams
        self.fatPerServing = item.macrosPerServing.fatGrams
        self.loggedAt = loggedAt
    }

    var item: FoodItem {
        FoodItem(
            id: foodID,
            name: name,
            brand: brand,
            servingDescription: servingDescription,
            macrosPerServing: MacroNutrients(
                calories: caloriesPerServing,
                proteinGrams: proteinPerServing,
                carbGrams: carbsPerServing,
                fatGrams: fatPerServing
            )
        )
    }

    var coreLog: FoodLogEntry {
        FoodLogEntry(
            id: id,
            food: item,
            servingMultiplier: servingMultiplier,
            loggedAt: loggedAt
        )
    }

    var macros: MacroNutrients {
        coreLog.macros
    }

    static func summary(
        for date: Date,
        logs: [FoodLogModel],
        calendar: Calendar = .current
    ) -> DailySummary {
        NutritionCalculator.summary(
            for: date,
            logs: logs.map(\.coreLog),
            calendar: calendar
        )
    }
}

@Model
final class BaseStateModel {
    @Attribute(.unique) var id: String
    var currency: Int
    var streak: Int
    var lastDayRewardDate: Date?
    var baseLevel: Int
    var decorLevel: Int
    var carbHabitatLevel: Int
    var proteinHabitatLevel: Int
    var fatHabitatLevel: Int

    init(
        id: String = "current",
        currency: Int = 0,
        streak: Int = 0,
        lastDayRewardDate: Date? = nil,
        baseLevel: Int = 0,
        decorLevel: Int = 0,
        carbHabitatLevel: Int = 0,
        proteinHabitatLevel: Int = 0,
        fatHabitatLevel: Int = 0
    ) {
        self.id = id
        self.currency = currency
        self.streak = streak
        self.lastDayRewardDate = lastDayRewardDate
        self.baseLevel = baseLevel
        self.decorLevel = decorLevel
        self.carbHabitatLevel = carbHabitatLevel
        self.proteinHabitatLevel = proteinHabitatLevel
        self.fatHabitatLevel = fatHabitatLevel
    }

    var upgradeState: UpgradeState {
        UpgradeState(
            currency: currency,
            levels: [
                UpgradeCatalog.baseExpansion.id: baseLevel,
                UpgradeCatalog.groveDecor.id: decorLevel,
                UpgradeCatalog.carbHabitat.id: carbHabitatLevel,
                UpgradeCatalog.proteinHabitat.id: proteinHabitatLevel,
                UpgradeCatalog.fatHabitat.id: fatHabitatLevel
            ]
        )
    }

    func level(for upgrade: Upgrade) -> Int {
        upgradeState.level(for: upgrade)
    }

    func apply(_ state: UpgradeState) {
        currency = state.currency
        baseLevel = state.levels[UpgradeCatalog.baseExpansion.id, default: baseLevel]
        decorLevel = state.levels[UpgradeCatalog.groveDecor.id, default: decorLevel]
        carbHabitatLevel = state.levels[UpgradeCatalog.carbHabitat.id, default: carbHabitatLevel]
        proteinHabitatLevel = state.levels[UpgradeCatalog.proteinHabitat.id, default: proteinHabitatLevel]
        fatHabitatLevel = state.levels[UpgradeCatalog.fatHabitat.id, default: fatHabitatLevel]
    }
}

@Model
final class CreatureModel {
    @Attribute(.unique) var id: UUID
    var kindRawValue: String
    var energy: Int
    var createdAt: Date
    var lastFedAt: Date

    init(
        id: UUID = UUID(),
        kind: CreatureKind,
        energy: Int,
        createdAt: Date = Date(),
        lastFedAt: Date = Date()
    ) {
        self.id = id
        self.kindRawValue = kind.rawValue
        self.energy = max(0, energy)
        self.createdAt = createdAt
        self.lastFedAt = lastFedAt
    }

    var kind: CreatureKind {
        get { CreatureKind(rawValue: kindRawValue) ?? .grainling }
        set { kindRawValue = newValue.rawValue }
    }

    func feed(energy amount: Int, date: Date = Date()) {
        energy += max(0, amount)
        lastFedAt = date
    }
}
