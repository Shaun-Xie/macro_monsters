import SwiftData
import SwiftUI

@main
struct MacroMonstersApp: App {
    private let container: ModelContainer = {
        let schema = Schema([
            UserGoalModel.self,
            FoodLogModel.self,
            BaseStateModel.self,
            CreatureModel.self
        ])
        let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppGateView()
        }
        .modelContainer(container)
    }
}
