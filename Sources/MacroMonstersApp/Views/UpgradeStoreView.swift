import MacroMonstersCore
import SwiftData
import SwiftUI

struct UpgradeStoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var baseStates: [BaseStateModel]
    @State private var message: String?

    private var base: BaseStateModel? {
        baseStates.first
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Currency", systemImage: "sparkles")
                        Spacer()
                        Text("\(base?.currency ?? 0)")
                            .font(.headline)
                    }
                }

                Section("Base Upgrades") {
                    ForEach(UpgradeCatalog.all) { upgrade in
                        UpgradeRow(
                            upgrade: upgrade,
                            level: base?.level(for: upgrade) ?? 0,
                            currency: base?.currency ?? 0
                        ) {
                            purchase(upgrade)
                        }
                    }
                }

                if let message {
                    Section {
                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Upgrades")
        }
    }

    private func purchase(_ upgrade: Upgrade) {
        do {
            let result = try AppStateStore.purchase(upgrade: upgrade, in: modelContext)
            message = result.message
        } catch {
            message = error.localizedDescription
        }
    }
}

private struct UpgradeRow: View {
    var upgrade: Upgrade
    var level: Int
    var currency: Int
    var onPurchase: () -> Void

    private var cost: Int {
        UpgradeRules.nextCost(for: upgrade, currentLevel: level)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(upgrade.name)
                    .font(.headline)
                Text(upgrade.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Level \(level) / \(upgrade.maxLevel)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onPurchase()
            } label: {
                Label("\(cost)", systemImage: "sparkles")
            }
            .buttonStyle(.bordered)
            .disabled(level >= upgrade.maxLevel || currency < cost)
            .accessibilityLabel("Buy \(upgrade.name)")
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch upgrade.category {
        case .base:
            return "square.grid.3x3.fill"
        case .decor:
            return "leaf.fill"
        case .carbHabitat:
            return "circle.hexagongrid.fill"
        case .proteinHabitat:
            return "bolt.fill"
        case .fatHabitat:
            return "drop.fill"
        }
    }

    private var tint: Color {
        switch upgrade.category {
        case .base:
            return MacroPalette.calories
        case .decor:
            return .teal
        case .carbHabitat:
            return MacroPalette.carbs
        case .proteinHabitat:
            return MacroPalette.protein
        case .fatHabitat:
            return MacroPalette.fat
        }
    }
}
