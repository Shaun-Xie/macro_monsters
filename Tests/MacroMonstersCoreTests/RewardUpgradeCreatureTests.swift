import XCTest
@testable import MacroMonstersCore

final class RewardUpgradeCreatureTests: XCTestCase {
    func testLoggingRewardIncreasesWithCaloriesAndMacroDiversity() {
        let snackReward = RewardEngine.loggingReward(
            for: MacroNutrients(calories: 100, proteinGrams: 0, carbGrams: 25, fatGrams: 0)
        )
        let mealReward = RewardEngine.loggingReward(
            for: MacroNutrients(calories: 650, proteinGrams: 35, carbGrams: 70, fatGrams: 20)
        )

        XCTAssertGreaterThan(mealReward, snackReward)
        XCTAssertEqual(RewardEngine.loggingReward(for: .zero), 0)
    }

    func testDayEndRewardPaysGoalAndStreakBonuses() {
        let goals = DailyGoals(calories: 2000, proteinGrams: 150, carbGrams: 240, fatGrams: 65)
        let summary = DailySummary(
            date: Date(),
            totals: MacroNutrients(calories: 1980, proteinGrams: 148, carbGrams: 235, fatGrams: 66),
            logCount: 5
        )

        let reward = RewardEngine.dayEndReward(summary: summary, goals: goals, currentStreak: 4)

        XCTAssertEqual(reward.goalBonusCurrency, RewardEngine.dailyGoalBonusCurrency)
        XCTAssertEqual(reward.streakBonusCurrency, 12)
        XCTAssertEqual(reward.total, 52)
    }

    func testUpgradePurchaseSpendsCurrencyAndRaisesLevel() {
        let upgrade = UpgradeCatalog.baseExpansion
        let state = UpgradeState(currency: 100, levels: [upgrade.id: 0])

        let result = UpgradeRules.purchase(upgrade: upgrade, state: state)

        XCTAssertTrue(result.didPurchase)
        XCTAssertEqual(result.state.currency, 40)
        XCTAssertEqual(result.state.level(for: upgrade), 1)
    }

    func testUpgradePurchaseFailsAtMaxLevel() {
        let upgrade = UpgradeCatalog.groveDecor
        let state = UpgradeState(currency: 1_000, levels: [upgrade.id: upgrade.maxLevel])

        let result = UpgradeRules.purchase(upgrade: upgrade, state: state)

        XCTAssertFalse(result.didPurchase)
        XCTAssertEqual(result.state.level(for: upgrade), upgrade.maxLevel)
    }

    func testCreatureEventsFollowMacroCategories() {
        let events = CreatureEngine.events(
            for: MacroNutrients(calories: 500, proteinGrams: 30, carbGrams: 45, fatGrams: 4)
        )

        XCTAssertTrue(events.contains { $0.kind == .flexling && $0.eventType == .spawn })
        XCTAssertTrue(events.contains { $0.kind == .grainling && $0.eventType == .spawn })
        XCTAssertTrue(events.contains { $0.kind == .oilkin && $0.eventType == .feed })
    }
}
