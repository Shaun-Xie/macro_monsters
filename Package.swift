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
        )
    ],
    targets: [
        .target(
            name: "MacroMonstersCore",
            path: "Sources/MacroMonstersCore"
        ),
        .testTarget(
            name: "MacroMonstersCoreTests",
            dependencies: ["MacroMonstersCore"],
            path: "Tests/MacroMonstersCoreTests"
        )
    ]
)
