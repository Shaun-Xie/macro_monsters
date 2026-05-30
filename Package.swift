// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MacroMonsters",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MacroMonstersCore",
            targets: ["MacroMonstersCore"]
        ),
        .library(
            name: "MacroMonstersFoodSearch",
            targets: ["MacroMonstersFoodSearch"]
        )
    ],
    targets: [
        .target(
            name: "MacroMonstersCore",
            path: "Sources/MacroMonstersCore"
        ),
        .target(
            name: "MacroMonstersFoodSearch",
            dependencies: ["MacroMonstersCore"],
            path: "Sources/MacroMonstersApp",
            exclude: [
                "App",
                "Game",
                "Models",
                "Supporting",
                "Services/AppStateStore.swift",
                "Views"
            ],
            sources: [
                "Services/FoodDataCentralClient.swift",
                "ViewModels/FoodSearchViewModel.swift"
            ]
        ),
        .testTarget(
            name: "MacroMonstersCoreTests",
            dependencies: ["MacroMonstersCore"],
            path: "Tests/MacroMonstersCoreTests"
        ),
        .testTarget(
            name: "MacroMonstersFoodSearchTests",
            dependencies: ["MacroMonstersFoodSearch"],
            path: "Tests/MacroMonstersFoodSearchTests"
        )
    ]
)
