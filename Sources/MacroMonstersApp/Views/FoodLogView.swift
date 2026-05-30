import MacroMonstersCore
import SwiftData
import SwiftUI

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = FoodSearchViewModel()
    @State private var servingMultiplier = 1.0
    @State private var isManualEntryPresented = false
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Search foods", text: $viewModel.query)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .accessibilityIdentifier("foodSearchField")
                        .onSubmit {
                            Task { await viewModel.search() }
                        }

                    Button {
                        Task { await viewModel.search() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Search")
                    .accessibilityIdentifier("foodSearchButton")
                }
                .padding(.horizontal)

                Stepper(
                    "Servings: \(servingMultiplier.formatted(.number.precision(.fractionLength(0...1))))",
                    value: $servingMultiplier,
                    in: 0.25...8,
                    step: 0.25
                )
                .padding(.horizontal)
                .accessibilityIdentifier("servingStepper")

                FoodSearchSourceView(mode: viewModel.searchMode)
                    .padding(.horizontal)

                if let statusMessage {
                    Text(statusMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }

                List {
                    if viewModel.isSearching {
                        HStack {
                            ProgressView()
                            Text("Searching foods...")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        FoodSearchMessageRow(
                            title: "Search unavailable",
                            message: errorMessage,
                            actionTitle: "Enter manually",
                            action: { isManualEntryPresented = true }
                        )
                    } else if viewModel.isEmptyResult {
                        FoodSearchMessageRow(
                            title: "No foods found",
                            message: "Try a different search or add the food manually.",
                            actionTitle: "Enter manually",
                            action: { isManualEntryPresented = true }
                        )
                    }

                    ForEach(viewModel.results) { result in
                        FoodSearchResultRow(result: result) {
                            addFood(result.foodItem, multiplier: servingMultiplier)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Log Food")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isManualEntryPresented = true
                    } label: {
                        Label("Manual Entry", systemImage: "square.and.pencil")
                    }
                    .accessibilityIdentifier("manualEntryButton")
                }
            }
            .sheet(isPresented: $isManualEntryPresented) {
                ManualFoodEntryView { item, multiplier in
                    addFood(item, multiplier: multiplier)
                    isManualEntryPresented = false
                }
            }
            .task {
                await viewModel.search()
            }
        }
    }

    private func addFood(_ item: FoodItem, multiplier: Double) {
        do {
            try AppStateStore.addFoodLog(item: item, servingMultiplier: multiplier, in: modelContext)
            statusMessage = "Logged \(item.name)."
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

private struct FoodSearchSourceView: View {
    var mode: FoodSearchMode

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: mode == .usda ? "network" : "tray")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.title)
                    .font(.caption.weight(.semibold))
                Text(mode.detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("foodSearchSourceState")
    }
}

private struct FoodSearchMessageRow: View {
    var title: String
    var message: String
    var actionTitle: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
            Button(actionTitle, action: action)
                .buttonStyle(.bordered)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
    }
}

private struct FoodSearchResultRow: View {
    var result: FoodSearchResult
    var onAdd: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)
                if let brand = result.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(Int(result.macrosPerServing.calories.rounded())) kcal | P \(Int(result.macrosPerServing.proteinGrams.rounded()))g C \(Int(result.macrosPerServing.carbGrams.rounded()))g F \(Int(result.macrosPerServing.fatGrams.rounded()))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(result.servingDescription)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add \(result.name)")
        }
        .padding(.vertical, 4)
    }
}
