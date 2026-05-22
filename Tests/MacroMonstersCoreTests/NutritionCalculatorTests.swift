import XCTest
@testable import MacroMonstersCore

final class NutritionCalculatorTests: XCTestCase {
    func testServingScalingMultipliesMacros() {
        let rice = FoodItem(
            name: "Rice",
            servingDescription: "1 cup",
            macrosPerServing: MacroNutrients(calories: 200, proteinGrams: 4, carbGrams: 44, fatGrams: 1)
        )
        let log = FoodLogEntry(food: rice, servingMultiplier: 1.5)

        XCTAssertEqual(log.macros.calories, 300, accuracy: 0.001)
        XCTAssertEqual(log.macros.proteinGrams, 6, accuracy: 0.001)
        XCTAssertEqual(log.macros.carbGrams, 66, accuracy: 0.001)
        XCTAssertEqual(log.macros.fatGrams, 1.5, accuracy: 0.001)
    }

    func testDailySummaryOnlyIncludesMatchingDay() {
        let calendar = Calendar(identifier: .gregorian)
        let targetDate = Date(timeIntervalSince1970: 1_700_000_000)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: targetDate)!
        let item = FoodItem(
            name: "Yogurt",
            servingDescription: "170 g",
            macrosPerServing: MacroNutrients(calories: 100, proteinGrams: 17, carbGrams: 6, fatGrams: 0)
        )
        let logs = [
            FoodLogEntry(food: item, servingMultiplier: 2, loggedAt: targetDate),
            FoodLogEntry(food: item, servingMultiplier: 1, loggedAt: yesterday)
        ]

        let summary = NutritionCalculator.summary(for: targetDate, logs: logs, calendar: calendar)

        XCTAssertEqual(summary.logCount, 1)
        XCTAssertEqual(summary.totals.calories, 200, accuracy: 0.001)
        XCTAssertEqual(summary.totals.proteinGrams, 34, accuracy: 0.001)
    }

    func testGoalEvaluationUsesCaloriesAsCompletionState() {
        let goals = DailyGoals(calories: 2000, proteinGrams: 150, carbGrams: 220, fatGrams: 70)
        let summary = DailySummary(
            date: Date(),
            totals: MacroNutrients(calories: 1800, proteinGrams: 140, carbGrams: 210, fatGrams: 68),
            logCount: 4
        )

        let evaluation = GoalEvaluator.evaluate(summary: summary, goals: goals)

        XCTAssertEqual(evaluation.calories.ratio, 0.9, accuracy: 0.001)
        XCTAssertEqual(evaluation.energyState, .steady)
        XCTAssertTrue(evaluation.isNearGoals)
    }
}
