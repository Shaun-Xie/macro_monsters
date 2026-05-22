import Foundation

public enum UpgradeCategory: String, CaseIterable, Codable, Sendable {
    case base
    case decor
    case carbHabitat
    case proteinHabitat
    case fatHabitat
}

public struct Upgrade: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var category: UpgradeCategory
    public var maxLevel: Int
    public var baseCost: Int
    public var description: String

    public init(
        id: String,
        name: String,
        category: UpgradeCategory,
        maxLevel: Int,
        baseCost: Int,
        description: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.maxLevel = max(1, maxLevel)
        self.baseCost = max(1, baseCost)
        self.description = description
    }
}

public struct UpgradeState: Codable, Equatable, Sendable {
    public var currency: Int
    public var levels: [String: Int]

    public init(currency: Int = 0, levels: [String: Int] = [:]) {
        self.currency = max(0, currency)
        self.levels = levels.mapValues { max(0, $0) }
    }

    public func level(for upgrade: Upgrade) -> Int {
        levels[upgrade.id, default: 0]
    }
}

public struct UpgradePurchaseResult: Codable, Equatable, Sendable {
    public var state: UpgradeState
    public var didPurchase: Bool
    public var message: String

    public init(state: UpgradeState, didPurchase: Bool, message: String) {
        self.state = state
        self.didPurchase = didPurchase
        self.message = message
    }
}

public enum UpgradeCatalog {
    public static let baseExpansion = Upgrade(
        id: "base_expansion",
        name: "Base Expansion",
        category: .base,
        maxLevel: 5,
        baseCost: 60,
        description: "Adds tiles and activity space to the isometric base."
    )

    public static let groveDecor = Upgrade(
        id: "grove_decor",
        name: "Nourish Grove",
        category: .decor,
        maxLevel: 4,
        baseCost: 35,
        description: "Adds trees, stones, and softer environmental detail."
    )

    public static let carbHabitat = Upgrade(
        id: "carb_habitat",
        name: "Grainling Mill",
        category: .carbHabitat,
        maxLevel: 4,
        baseCost: 45,
        description: "Improves the zone that attracts carb-focused Nourishlings."
    )

    public static let proteinHabitat = Upgrade(
        id: "protein_habitat",
        name: "Amino Forge",
        category: .proteinHabitat,
        maxLevel: 4,
        baseCost: 45,
        description: "Improves the zone that attracts protein-focused Nourishlings."
    )

    public static let fatHabitat = Upgrade(
        id: "fat_habitat",
        name: "Oilkin Springs",
        category: .fatHabitat,
        maxLevel: 4,
        baseCost: 45,
        description: "Improves the zone that attracts fat-focused Nourishlings."
    )

    public static let all: [Upgrade] = [
        baseExpansion,
        groveDecor,
        carbHabitat,
        proteinHabitat,
        fatHabitat
    ]

    public static func upgrade(id: String) -> Upgrade? {
        all.first { $0.id == id }
    }
}

public enum UpgradeRules {
    public static func nextCost(for upgrade: Upgrade, currentLevel: Int) -> Int {
        let safeLevel = max(0, currentLevel)
        return upgrade.baseCost + (safeLevel * upgrade.baseCost / 2)
    }

    public static func canPurchase(upgrade: Upgrade, state: UpgradeState) -> Bool {
        let currentLevel = state.level(for: upgrade)
        return currentLevel < upgrade.maxLevel && state.currency >= nextCost(for: upgrade, currentLevel: currentLevel)
    }

    public static func purchase(upgrade: Upgrade, state: UpgradeState) -> UpgradePurchaseResult {
        let currentLevel = state.level(for: upgrade)

        guard currentLevel < upgrade.maxLevel else {
            return UpgradePurchaseResult(state: state, didPurchase: false, message: "Already at max level.")
        }

        let cost = nextCost(for: upgrade, currentLevel: currentLevel)
        guard state.currency >= cost else {
            return UpgradePurchaseResult(state: state, didPurchase: false, message: "Not enough currency.")
        }

        var levels = state.levels
        levels[upgrade.id] = currentLevel + 1
        let updatedState = UpgradeState(currency: state.currency - cost, levels: levels)
        return UpgradePurchaseResult(state: updatedState, didPurchase: true, message: "Purchased \(upgrade.name).")
    }
}
