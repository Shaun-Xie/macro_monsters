import SwiftData
import SwiftUI

struct AppGateView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserGoalModel.updatedAt, order: .reverse) private var goals: [UserGoalModel]

    var body: some View {
        Group {
            if goals.first == nil {
                OnboardingView()
            } else {
                RootTabView()
            }
        }
        .task {
            let base = AppStateStore.ensureBaseState(in: modelContext)
            if ProcessInfo.processInfo.arguments.contains("--ui-testing-seed-currency") {
                base.currency = max(base.currency, 500)
            }
            try? modelContext.save()
            AppStateStore.writeWidgetSnapshot(in: modelContext)
        }
    }
}
