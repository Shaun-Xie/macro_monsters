import Foundation

public enum CreatureKind: String, CaseIterable, Codable, Sendable {
    case grainling
    case flexling
    case oilkin

    public var displayName: String {
        switch self {
        case .grainling:
            return "Grainling"
        case .flexling:
            return "Flexling"
        case .oilkin:
            return "Oilkin"
        }
    }

    public var nutrientKind: NutrientKind {
        switch self {
        case .grainling:
            return .carbs
        case .flexling:
            return .protein
        case .oilkin:
            return .fat
        }
    }
}

public enum CreatureEventType: String, Codable, Sendable {
    case spawn
    case feed
}

public struct CreatureEvent: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var kind: CreatureKind
    public var eventType: CreatureEventType
    public var energy: Int

    public init(
        id: UUID = UUID(),
        kind: CreatureKind,
        eventType: CreatureEventType,
        energy: Int
    ) {
        self.id = id
        self.kind = kind
        self.eventType = eventType
        self.energy = max(0, energy)
    }
}

public enum CreatureEngine {
    public static func events(for macros: MacroNutrients) -> [CreatureEvent] {
        guard macros.calories > 0 else {
            return []
        }

        let candidates: [(CreatureKind, Double, Double)] = [
            (.grainling, macros.carbGrams, 25),
            (.flexling, macros.proteinGrams, 25),
            (.oilkin, macros.fatGrams, 12)
        ]

        return candidates.compactMap { kind, grams, spawnThreshold in
            guard grams > 0 else {
                return nil
            }

            let eventType: CreatureEventType = grams >= spawnThreshold ? .spawn : .feed
            let energy = Int((grams * 2).rounded(.toNearestOrAwayFromZero))
            return CreatureEvent(kind: kind, eventType: eventType, energy: energy)
        }
    }
}
