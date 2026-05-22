import SpriteKit
import SwiftData
import SwiftUI

struct BaseContainerView: View {
    @Query private var baseStates: [BaseStateModel]
    @Query(sort: \CreatureModel.createdAt, order: .forward) private var creatures: [CreatureModel]
    @State private var scene = IsometricBaseScene()

    private var base: BaseStateModel? {
        baseStates.first
    }

    private var sceneSignature: String {
        [
            base?.baseLevel ?? 0,
            base?.decorLevel ?? 0,
            base?.carbHabitatLevel ?? 0,
            base?.proteinHabitatLevel ?? 0,
            base?.fatHabitatLevel ?? 0,
            creatures.count
        ]
        .map(String.init)
        .joined(separator: "-")
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .ignoresSafeArea(edges: .bottom)
                    .background(Color(red: 0.10, green: 0.16, blue: 0.14))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Base Level \((base?.baseLevel ?? 0) + 1)")
                        .font(.headline)
                    Text("\(creatures.count) Nourishlings roaming")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding()
            }
            .navigationTitle("Base")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: syncScene)
            .onChange(of: sceneSignature) { _ in
                syncScene()
            }
        }
    }

    private func syncScene() {
        scene.configure(
            baseLevel: base?.baseLevel ?? 0,
            decorLevel: base?.decorLevel ?? 0,
            carbHabitatLevel: base?.carbHabitatLevel ?? 0,
            proteinHabitatLevel: base?.proteinHabitatLevel ?? 0,
            fatHabitatLevel: base?.fatHabitatLevel ?? 0,
            creatures: creatures.map(\.kind)
        )
    }
}
