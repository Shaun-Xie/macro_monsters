# Macro Monsters

Macro Monsters is a native iOS MVP for a gamified macro tracker. The app tracks calories, protein, carbs, and fat, then turns logged food into Nourishling creature activity, currency, base upgrades, and WidgetKit snapshots.

## Stack

- Swift + SwiftUI for the app
- SwiftData for local persistence
- SpriteKit embedded in SwiftUI for the fixed isometric base
- WidgetKit + SwiftUI for progress and base widgets
- USDA FoodData Central search when `FDC_API_KEY` is configured
- Manual food entry and local sample foods as the offline fallback

## Repository Layout

- `Sources/MacroMonstersCore`: testable nutrition, reward, upgrade, creature, and widget snapshot logic
- `Sources/MacroMonstersApp`: SwiftUI app, SwiftData models, USDA search, and SpriteKit base scene
- `Sources/MacroMonstersWidgets`: Progress and Base WidgetKit configurations
- `Tests/MacroMonstersCoreTests`: unit tests for core loop rules
- `Tests/MacroMonstersUITests`: UI test skeleton for onboarding, manual food logging, and upgrades
- `project.yml`: XcodeGen project definition
- `Package.swift`: Swift Package for the pure core library and unit tests
- `CODEX_HANDOFF.md`: concise continuation context for future Codex chats
- `DEVELOPMENT_PLAN.md`: living roadmap and prioritized backlog

## macOS Setup

1. Install Xcode 15 or newer.
2. Install XcodeGen:

   ```sh
   brew install xcodegen
   ```

3. Generate the Xcode project:

   ```sh
   xcodegen generate
   ```

4. Open `MacroMonsters.xcodeproj`.
5. Select the `MacroMonsters` scheme and run on an iOS 17+ simulator.

If using the current Mac setup, the verified simulator is `iPhone 17` with id `5CC012F4-2DB0-4725-B435-69B851D7746D`.

## Food Search

Set `FDC_API_KEY` as an Xcode build setting to enable USDA FoodData Central search. If the key is absent, the app uses local sample foods and manual entry still works.

## Tests

The core logic is isolated so it can be tested without launching the app:

```sh
SWIFTPM_HOME="$PWD/.build/swiftpm-home" CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-module-cache" swift test
```

Build the app from the command line:

```sh
xcodebuild build \
  -project MacroMonsters.xcodeproj \
  -scheme MacroMonsters \
  -destination 'id=5CC012F4-2DB0-4725-B435-69B851D7746D'
```

Run the generated Xcode test schemes:

```sh
xcodebuild test \
  -project MacroMonsters.xcodeproj \
  -scheme MacroMonstersCore \
  -destination 'id=5CC012F4-2DB0-4725-B435-69B851D7746D'
```

```sh
xcodebuild test \
  -project MacroMonsters.xcodeproj \
  -scheme MacroMonsters \
  -destination 'id=5CC012F4-2DB0-4725-B435-69B851D7746D'
```

Widget rendering should also be checked manually in small and medium families because widgets use static timelines rather than live SpriteKit animation.

## Continuing Development

Read `CODEX_HANDOFF.md` and `DEVELOPMENT_PLAN.md` at the start of each new development session. The current recommended next slice is food search and API reliability.
