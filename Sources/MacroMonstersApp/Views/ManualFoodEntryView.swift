import MacroMonstersCore
import SwiftUI

struct ManualFoodEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var servingDescription = "1 serving"
    @State private var servings = 1.0
    @State private var calories = 0.0
    @State private var protein = 0.0
    @State private var carbs = 0.0
    @State private var fat = 0.0

    var onSave: (FoodItem, Double) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("manualFoodNameField")
                    TextField("Serving", text: $servingDescription)
                    TextField("Servings", value: $servings, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("manualServingsField")
                }

                Section("Macros Per Serving") {
                    TextField("Calories", value: $calories, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("manualCaloriesField")
                    TextField("Protein", value: $protein, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("manualProteinField")
                    TextField("Carbs", value: $carbs, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("manualCarbsField")
                    TextField("Fat", value: $fat, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("manualFatField")
                }
            }
            .navigationTitle("Manual Food")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = FoodItem(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            servingDescription: servingDescription,
                            macrosPerServing: MacroNutrients(
                                calories: calories,
                                proteinGrams: protein,
                                carbGrams: carbs,
                                fatGrams: fat
                            )
                        )
                        onSave(item, max(0, servings))
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || calories <= 0)
                    .accessibilityIdentifier("manualAddButton")
                }
            }
        }
    }
}
