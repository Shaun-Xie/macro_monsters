import Foundation

public enum AppGroup {
    public static let suiteName = "group.com.sxxie.macromonsters"
}

public struct WidgetSnapshot: Codable, Equatable, Sendable {
    public var date: Date
    public var goals: DailyGoals?
    public var summary: DailySummary
    public var currency: Int
    public var streak: Int
    public var baseLevel: Int
    public var carbHabitatLevel: Int
    public var proteinHabitatLevel: Int
    public var fatHabitatLevel: Int
    public var decorLevel: Int

    public init(
        date: Date = Date(),
        goals: DailyGoals? = nil,
        summary: DailySummary = DailySummary(date: Date()),
        currency: Int = 0,
        streak: Int = 0,
        baseLevel: Int = 0,
        carbHabitatLevel: Int = 0,
        proteinHabitatLevel: Int = 0,
        fatHabitatLevel: Int = 0,
        decorLevel: Int = 0
    ) {
        self.date = date
        self.goals = goals
        self.summary = summary
        self.currency = max(0, currency)
        self.streak = max(0, streak)
        self.baseLevel = max(0, baseLevel)
        self.carbHabitatLevel = max(0, carbHabitatLevel)
        self.proteinHabitatLevel = max(0, proteinHabitatLevel)
        self.fatHabitatLevel = max(0, fatHabitatLevel)
        self.decorLevel = max(0, decorLevel)
    }

    public static let empty = WidgetSnapshot()
}

public final class WidgetSnapshotStore {
    private let key = "macro_monsters_widget_snapshot"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(suiteName: String = AppGroup.suiteName) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    public func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? encoder.encode(snapshot) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    public func load() -> WidgetSnapshot {
        guard
            let data = defaults.data(forKey: key),
            let snapshot = try? decoder.decode(WidgetSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }
}
