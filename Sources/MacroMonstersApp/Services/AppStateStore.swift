import Foundation
import MacroMonstersCore
import SwiftData
import WidgetKit

@MainActor
enum AppStateStore {
    static func ensureBaseState(in context: ModelContext) -> BaseStateModel {
        let descriptor = FetchDescriptor<BaseStateModel>()
        if let states = try? context.fetch(descriptor), let existing = states.first {
            return existing
        }

        let baseState = BaseStateModel()
        context.insert(baseState)
        return baseState
    }

    static func currentGoals(in context: ModelContext) -> DailyGoals? {
        var descriptor = FetchDescriptor<UserGoalModel>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        guard let goals = try? context.fetch(descriptor) else {
            return nil
        }
        return goals.first?.coreGoals
    }

    static func todaySummary(in context: ModelContext, calendar: Calendar = .current) -> DailySummary {
        let descriptor = FetchDescriptor<FoodLogModel>()
        let logs = (try? context.fetch(descriptor)) ?? []
        return FoodLogModel.summary(for: Date(), logs: logs, calendar: calendar)
    }

    static func addFoodLog(
        item: FoodItem,
        servingMultiplier: Double,
        in context: ModelContext
    ) throws {
        let log = FoodLogModel(item: item, servingMultiplier: servingMultiplier)
        context.insert(log)

        let base = ensureBaseState(in: context)
        base.currency += RewardEngine.loggingReward(for: log.macros)
        applyCreatureEvents(for: log.macros, in: context)

        try context.save()
        writeWidgetSnapshot(in: context)
    }

    static func purchase(
        upgrade: Upgrade,
        in context: ModelContext
    ) throws -> UpgradePurchaseResult {
        let base = ensureBaseState(in: context)
        let result = UpgradeRules.purchase(upgrade: upgrade, state: base.upgradeState)

        if result.didPurchase {
            base.apply(result.state)
            try context.save()
            writeWidgetSnapshot(in: context)
        }

        return result
    }

    static func claimDayEndReward(in context: ModelContext, calendar: Calendar = .current) throws -> RewardBreakdown {
        guard let goals = currentGoals(in: context) else {
            return RewardBreakdown()
        }

        let base = ensureBaseState(in: context)
        let now = Date()
        if let lastDayRewardDate = base.lastDayRewardDate,
           calendar.isDate(lastDayRewardDate, inSameDayAs: now) {
            return RewardBreakdown()
        }

        let summary = todaySummary(in: context, calendar: calendar)
        guard summary.logCount > 0 else {
            return RewardBreakdown()
        }

        let continuesStreak = base.lastDayRewardDate.map {
            calendar.isDate($0, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now)
        } ?? false
        let nextStreak = continuesStreak ? base.streak + 1 : 1
        let reward = RewardEngine.dayEndReward(
            summary: summary,
            goals: goals,
            currentStreak: nextStreak
        )

        base.currency += reward.total
        base.streak = nextStreak
        base.lastDayRewardDate = now
        try context.save()
        writeWidgetSnapshot(in: context)
        return reward
    }

    static func writeWidgetSnapshot(in context: ModelContext) {
        let base = ensureBaseState(in: context)
        let goals = currentGoals(in: context)
        let summary = todaySummary(in: context)
        let snapshot = WidgetSnapshot(
            date: Date(),
            goals: goals,
            summary: summary,
            currency: base.currency,
            streak: base.streak,
            baseLevel: base.baseLevel,
            carbHabitatLevel: base.carbHabitatLevel,
            proteinHabitatLevel: base.proteinHabitatLevel,
            fatHabitatLevel: base.fatHabitatLevel,
            decorLevel: base.decorLevel
        )

        WidgetSnapshotStore().save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func applyCreatureEvents(for macros: MacroNutrients, in context: ModelContext) {
        let events = CreatureEngine.events(for: macros)
        guard !events.isEmpty else {
            return
        }

        let descriptor = FetchDescriptor<CreatureModel>()
        let existingCreatures = (try? context.fetch(descriptor)) ?? []

        for event in events {
            if event.eventType == .spawn || existingCreatures.first(where: { $0.kind == event.kind }) == nil {
                context.insert(CreatureModel(kind: event.kind, energy: event.energy))
            } else if let creature = existingCreatures.first(where: { $0.kind == event.kind }) {
                creature.feed(energy: event.energy)
            }
        }
    }
}
