import MacroMonstersCore
import SwiftUI

enum MacroPalette {
    static let calories = Color(red: 0.20, green: 0.43, blue: 0.72)
    static let protein = Color(red: 0.19, green: 0.56, blue: 0.36)
    static let carbs = Color(red: 0.83, green: 0.52, blue: 0.18)
    static let fat = Color(red: 0.74, green: 0.28, blue: 0.42)
    static let surface = Color(.secondarySystemBackground)
}

struct MacroProgressBar: View {
    var title: String
    var progress: NutrientProgress
    var unit: String
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(progress.current.rounded())) / \(Int(progress.target.rounded())) \(unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                    Capsule()
                        .fill(tint)
                        .frame(width: geometry.size.width * progress.cappedRatio)
                }
            }
            .frame(height: 10)
            .accessibilityLabel(title)
            .accessibilityValue("\(Int((progress.cappedRatio * 100).rounded())) percent")
        }
    }
}

struct StatPill: View {
    var title: String
    var value: String
    var systemImage: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(MacroPalette.surface, in: RoundedRectangle(cornerRadius: 8))
    }
}
