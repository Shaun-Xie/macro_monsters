import Foundation

public enum NutrientKind: String, CaseIterable, Codable, Sendable {
    case calories
    case protein
    case carbs
    case fat
}

public struct NutrientProgress: Codable, Equatable, Sendable {
    public var kind: NutrientKind
    public var current: Double
    public var target: Double
    public var ratio: Double

    public init(kind: NutrientKind, current: Double, target: Double, ratio: Double) {
        self.kind = kind
        self.current = current
        self.target = target
        self.ratio = ratio
    }

    public var cappedRatio: Double {
        min(1, max(0, ratio))
    }

    public var isComplete: Bool {
        ratio >= 1
    }
}

public enum DailyEnergyState: String, Codable, Sendable {
    case empty
    case low
    case steady
    case complete
    case over
}

public struct GoalTolerance: Codable, Equatable, Sendable {
    public var caloriesPercent: Double
    public var macroPercent: Double

    public init(caloriesPercent: Double = 0.10, macroPercent: Double = 0.15) {
        self.caloriesPercent = max(0, caloriesPercent)
        self.macroPercent = max(0, macroPercent)
    }
}

public struct DailyGoalEvaluation: Codable, Equatable, Sendable {
    public var calories: NutrientProgress
    public var protein: NutrientProgress
    public var carbs: NutrientProgress
    public var fat: NutrientProgress
    public var energyState: DailyEnergyState
    public var isNearGoals: Bool

    public init(
        calories: NutrientProgress,
        protein: NutrientProgress,
        carbs: NutrientProgress,
        fat: NutrientProgress,
        energyState: DailyEnergyState,
        isNearGoals: Bool
    ) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.energyState = energyState
        self.isNearGoals = isNearGoals
    }
}

public enum GoalEvaluator {
    public static func evaluate(
        summary: DailySummary,
        goals: DailyGoals,
        tolerance: GoalTolerance = GoalTolerance()
    ) -> DailyGoalEvaluation {
        let calories = progress(kind: .calories, current: summary.totals.calories, target: goals.calories)
        let protein = progress(kind: .protein, current: summary.totals.proteinGrams, target: goals.proteinGrams)
        let carbs = progress(kind: .carbs, current: summary.totals.carbGrams, target: goals.carbGrams)
        let fat = progress(kind: .fat, current: summary.totals.fatGrams, target: goals.fatGrams)

        return DailyGoalEvaluation(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            energyState: energyState(for: calories.ratio),
            isNearGoals: isNear(summary: summary, goals: goals, tolerance: tolerance)
        )
    }

    public static func progress(kind: NutrientKind, current: Double, target: Double) -> NutrientProgress {
        let safeCurrent = max(0, current)
        let safeTarget = max(0, target)
        let ratio = safeTarget > 0 ? safeCurrent / safeTarget : (safeCurrent > 0 ? 1 : 0)
        return NutrientProgress(kind: kind, current: safeCurrent, target: safeTarget, ratio: ratio)
    }

    public static func energyState(for calorieRatio: Double) -> DailyEnergyState {
        switch calorieRatio {
        case ..<0.05:
            return .empty
        case ..<0.50:
            return .low
        case ..<1.0:
            return .steady
        case ...1.10:
            return .complete
        default:
            return .over
        }
    }

    public static func isNear(
        summary: DailySummary,
        goals: DailyGoals,
        tolerance: GoalTolerance = GoalTolerance()
    ) -> Bool {
        isWithin(summary.totals.calories, target: goals.calories, tolerance: tolerance.caloriesPercent) &&
        isWithin(summary.totals.proteinGrams, target: goals.proteinGrams, tolerance: tolerance.macroPercent) &&
        isWithin(summary.totals.carbGrams, target: goals.carbGrams, tolerance: tolerance.macroPercent) &&
        isWithin(summary.totals.fatGrams, target: goals.fatGrams, tolerance: tolerance.macroPercent)
    }

    private static func isWithin(_ value: Double, target: Double, tolerance: Double) -> Bool {
        guard target > 0 else {
            return value == 0
        }
        let lowerBound = target * (1 - tolerance)
        let upperBound = target * (1 + tolerance)
        return value >= lowerBound && value <= upperBound
    }
}
