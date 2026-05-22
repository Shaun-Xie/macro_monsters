import Foundation

public struct RewardBreakdown: Codable, Equatable, Sendable {
    public var loggingCurrency: Int
    public var goalBonusCurrency: Int
    public var streakBonusCurrency: Int

    public init(loggingCurrency: Int = 0, goalBonusCurrency: Int = 0, streakBonusCurrency: Int = 0) {
        self.loggingCurrency = max(0, loggingCurrency)
        self.goalBonusCurrency = max(0, goalBonusCurrency)
        self.streakBonusCurrency = max(0, streakBonusCurrency)
    }

    public var total: Int {
        loggingCurrency + goalBonusCurrency + streakBonusCurrency
    }
}

public enum RewardEngine {
    public static let baseLoggingCurrency = 5
    public static let dailyGoalBonusCurrency = 40
    public static let maxStreakBonusCurrency = 30

    public static func loggingReward(for macros: MacroNutrients) -> Int {
        guard macros.calories > 0 else {
            return 0
        }

        let representedMacros = [
            macros.proteinGrams,
            macros.carbGrams,
            macros.fatGrams
        ].filter { $0 > 0 }.count

        let calorieBonus = min(8, Int(macros.calories / 125))
        return baseLoggingCurrency + representedMacros + calorieBonus
    }

    public static func dayEndReward(
        summary: DailySummary,
        goals: DailyGoals,
        currentStreak: Int,
        tolerance: GoalTolerance = GoalTolerance()
    ) -> RewardBreakdown {
        let goalBonus = GoalEvaluator.isNear(summary: summary, goals: goals, tolerance: tolerance)
            ? dailyGoalBonusCurrency
            : 0
        let streakBonus = min(max(0, currentStreak), 10) * 3
        return RewardBreakdown(goalBonusCurrency: goalBonus, streakBonusCurrency: min(streakBonus, maxStreakBonusCurrency))
    }
}
