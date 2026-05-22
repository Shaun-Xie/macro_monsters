import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var calories = 2200.0
    @State private var proteinGrams = 150.0
    @State private var carbGrams = 240.0
    @State private var fatGrams = 70.0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Calories", value: $calories, format: .number)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("goalCaloriesField")
                    TextField("Protein", value: $proteinGrams, format: .number)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("goalProteinField")
                    TextField("Carbs", value: $carbGrams, format: .number)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("goalCarbsField")
                    TextField("Fat", value: $fatGrams, format: .number)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("goalFatField")
                } header: {
                    Text("Daily Goals")
                }

                Section {
                    Button {
                        saveGoals()
                    } label: {
                        Label("Start Tracking", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityIdentifier("startTrackingButton")
                }
            }
            .navigationTitle("Macro Monsters")
        }
    }

    private func saveGoals() {
        let goals = UserGoalModel(
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams
        )
        modelContext.insert(goals)
        _ = AppStateStore.ensureBaseState(in: modelContext)
        try? modelContext.save()
        AppStateStore.writeWidgetSnapshot(in: modelContext)
    }
}
