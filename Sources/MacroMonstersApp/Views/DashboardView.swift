import MacroMonstersCore
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodLogModel.loggedAt, order: .reverse) private var logs: [FoodLogModel]
    @Query(sort: \UserGoalModel.updatedAt, order: .reverse) private var goals: [UserGoalModel]
    @Query private var baseStates: [BaseStateModel]
    @State private var rewardMessage: String?

    private var goal: DailyGoals? {
        goals.first?.coreGoals
    }

    private var summary: DailySummary {
        FoodLogModel.summary(for: Date(), logs: logs)
    }

    private var base: BaseStateModel? {
        baseStates.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        StatPill(
                            title: "Currency",
                            value: "\(base?.currency ?? 0)",
                            systemImage: "sparkles"
                        )
                        StatPill(
                            title: "Streak",
                            value: "\(base?.streak ?? 0)",
                            systemImage: "flame.fill"
                        )
                    }

                    if let goal {
                        let evaluation = GoalEvaluator.evaluate(summary: summary, goals: goal)
                        VStack(spacing: 14) {
                            MacroProgressBar(
                                title: "Calories",
                                progress: evaluation.calories,
                                unit: "kcal",
                                tint: MacroPalette.calories
                            )
                            MacroProgressBar(
                                title: "Protein",
                                progress: evaluation.protein,
                                unit: "g",
                                tint: MacroPalette.protein
                            )
                            MacroProgressBar(
                                title: "Carbs",
                                progress: evaluation.carbs,
                                unit: "g",
                                tint: MacroPalette.carbs
                            )
                            MacroProgressBar(
                                title: "Fat",
                                progress: evaluation.fat,
                                unit: "g",
                                tint: MacroPalette.fat
                            )
                        }
                        .padding(16)
                        .background(MacroPalette.surface, in: RoundedRectangle(cornerRadius: 8))

                        Button {
                            claimReward()
                        } label: {
                            Label("Claim Day Bonus", systemImage: "gift.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("claimDayBonusButton")
                    }

                    if let rewardMessage {
                        Text(rewardMessage)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    recentLogs
                }
                .padding()
            }
            .navigationTitle("Today")
            .accessibilityIdentifier("todayDashboard")
        }
    }

    private var recentLogs: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Logs")
                .font(.headline)
            if logs.isEmpty {
                ContentUnavailableView("No food logged", systemImage: "fork.knife")
            } else {
                ForEach(logs.prefix(5)) { log in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.name)
                                .font(.subheadline.weight(.semibold))
                            Text("\(log.servingMultiplier.formatted(.number.precision(.fractionLength(0...1)))) x \(log.servingDescription)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(Int(log.macros.calories.rounded())) kcal")
                            .font(.subheadline)
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func claimReward() {
        do {
            let reward = try AppStateStore.claimDayEndReward(in: modelContext)
            rewardMessage = reward.total > 0
                ? "Earned \(reward.total) currency."
                : "Day bonus already claimed or goals are not ready."
        } catch {
            rewardMessage = error.localizedDescription
        }
    }
}
