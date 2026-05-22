import MacroMonstersCore
import SwiftUI
import WidgetKit

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct SnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: Date(), snapshot: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(SnapshotEntry(date: Date(), snapshot: WidgetSnapshotStore().load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let entry = SnapshotEntry(date: Date(), snapshot: WidgetSnapshotStore().load())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct ProgressWidget: Widget {
    let kind = "MacroMonstersProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SnapshotProvider()) { entry in
            ProgressWidgetView(entry: entry)
        }
        .configurationDisplayName("Macro Progress")
        .description("Calories and macro progress for today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BaseWidget: Widget {
    let kind = "MacroMonstersBaseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SnapshotProvider()) { entry in
            BaseWidgetView(entry: entry)
        }
        .configurationDisplayName("Monster Base")
        .description("A static snapshot of your Macro Monsters base.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct MacroMonstersWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProgressWidget()
        BaseWidget()
    }
}

private struct ProgressWidgetView: View {
    var entry: SnapshotEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if let goals = entry.snapshot.goals {
                let evaluation = GoalEvaluator.evaluate(summary: entry.snapshot.summary, goals: goals)
                VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 10) {
                    HStack {
                        Text("Macro Monsters")
                            .font(.caption.weight(.semibold))
                        Spacer()
                        Text("\(entry.snapshot.currency)")
                            .font(.caption2.weight(.bold))
                    }
                    WidgetBar(title: "Cal", progress: evaluation.calories, tint: .blue)
                    WidgetBar(title: "P", progress: evaluation.protein, tint: .green)
                    WidgetBar(title: "C", progress: evaluation.carbs, tint: .orange)
                    WidgetBar(title: "F", progress: evaluation.fat, tint: .pink)
                }
            } else {
                ContentUnavailableView("Set goals", systemImage: "chart.pie")
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

private struct WidgetBar: View {
    var title: String
    var progress: NutrientProgress
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(title)
                    .font(.caption2.weight(.semibold))
                Spacer()
                Text("\(Int((progress.cappedRatio * 100).rounded()))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.18))
                    Capsule()
                        .fill(tint)
                        .frame(width: geometry.size.width * progress.cappedRatio)
                }
            }
            .frame(height: 6)
        }
    }
}

private struct BaseWidgetView: View {
    var entry: SnapshotEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.16, blue: 0.14)
            IsometricBaseSnapshot(snapshot: entry.snapshot)
                .padding(.top, family == .systemSmall ? 18 : 8)
            VStack {
                HStack {
                    Text("Base \(entry.snapshot.baseLevel + 1)")
                        .font(.caption.weight(.bold))
                    Spacer()
                    Text("\(entry.snapshot.streak)d")
                        .font(.caption2.weight(.semibold))
                }
                Spacer()
            }
            .padding(12)
            .foregroundStyle(.white)
        }
        .containerBackground(.background, for: .widget)
    }
}

private struct IsometricBaseSnapshot: View {
    var snapshot: WidgetSnapshot

    private var radius: Int {
        2 + snapshot.baseLevel
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(tileCoordinates, id: \.self) { coordinate in
                    Diamond()
                        .fill(tileColor(coordinate))
                        .frame(width: 36, height: 18)
                        .position(position(for: coordinate, in: geometry.size))
                }

                habitat(color: .orange, offset: CGSize(width: -34, height: -12), level: snapshot.carbHabitatLevel)
                habitat(color: .green, offset: CGSize(width: 34, height: -2), level: snapshot.proteinHabitatLevel)
                habitat(color: .pink, offset: CGSize(width: 0, height: -34), level: snapshot.fatHabitatLevel)

                Diamond()
                    .fill(Color(red: 0.62, green: 0.70, blue: 0.58))
                    .frame(width: 48, height: 24)
                    .overlay(Text("MM").font(.caption2.weight(.bold)).foregroundStyle(.white))
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.56)
            }
        }
    }

    private var tileCoordinates: [TileCoordinate] {
        var coordinates: [TileCoordinate] = []
        for x in -radius...radius {
            for y in -radius...radius where abs(x) + abs(y) <= radius + 1 {
                coordinates.append(TileCoordinate(x: x, y: y))
            }
        }
        return coordinates
    }

    private func position(for coordinate: TileCoordinate, in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width / 2 + CGFloat(coordinate.x - coordinate.y) * 18,
            y: size.height * 0.58 + CGFloat(coordinate.x + coordinate.y) * 9
        )
    }

    private func tileColor(_ coordinate: TileCoordinate) -> Color {
        let baseGreen = (coordinate.x + coordinate.y).isMultiple(of: 2) ? 0.36 : 0.31
        return Color(red: 0.22, green: baseGreen + Double(snapshot.decorLevel) * 0.02, blue: 0.24)
    }

    @ViewBuilder
    private func habitat(color: Color, offset: CGSize, level: Int) -> some View {
        if level > 0 {
            Diamond()
                .fill(color)
                .frame(width: CGFloat(34 + level * 3), height: CGFloat(18 + level * 2))
                .offset(offset)
        }
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct TileCoordinate: Hashable {
    var x: Int
    var y: Int
}

private extension WidgetSnapshot {
    static var sample: WidgetSnapshot {
        WidgetSnapshot(
            goals: DailyGoals(calories: 2200, proteinGrams: 150, carbGrams: 240, fatGrams: 70),
            summary: DailySummary(
                date: Date(),
                totals: MacroNutrients(calories: 1320, proteinGrams: 88, carbGrams: 150, fatGrams: 42),
                logCount: 4
            ),
            currency: 128,
            streak: 3,
            baseLevel: 2,
            carbHabitatLevel: 1,
            proteinHabitatLevel: 2,
            fatHabitatLevel: 1,
            decorLevel: 2
        )
    }
}
