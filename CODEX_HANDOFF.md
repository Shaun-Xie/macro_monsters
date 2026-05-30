# Codex Handoff: Macro Monsters

Use this file as the first context document when continuing Macro Monsters in a new Codex chat.

## Current Repository State

- Repository: `https://github.com/Shaun-Xie/macro_monsters`
- Primary target: polished native iOS release
- Current direction: native SwiftUI/SpriteKit/WidgetKit app, not a PWA
- Project generation: `MacroMonsters.xcodeproj` is generated from `project.yml` with XcodeGen
- Known working simulator: `iPhone 17`, id `5CC012F4-2DB0-4725-B435-69B851D7746D`, iOS 26.5
- Build and tests pass after the first Mac/Xcode validation pass

## Continuation Prompt For Codex CLI

Paste this into Codex CLI from the repository root:

```text
Continue development on Macro Monsters.

Context:
- This is a native iOS app MVP, not a PWA.
- Stack: SwiftUI app, SwiftData local persistence, SpriteKit fixed-isometric base scene, WidgetKit widgets, MacroMonstersCore Swift package for testable product logic.
- Read README.md, CODEX_HANDOFF.md, DEVELOPMENT_PLAN.md, project.yml, Package.swift, Sources/, and Tests/ before editing.
- Preserve the current product direction: calorie/macro tracking, Nourishling creature loop, currency rewards, base upgrades, progress widget, base widget.
- Start from the highest-priority incomplete item in DEVELOPMENT_PLAN.md unless I give a more specific task.
- Before ending a development slice, update CODEX_HANDOFF.md and DEVELOPMENT_PLAN.md with what changed, commands run, results, and the recommended next task.
```

## Product Direction To Preserve

Macro Monsters should prove this MVP loop:

- User sets daily goals for calories, protein, carbs, and fat.
- User logs food through search or manual entry.
- Logged macros spawn, feed, or energize Nourishlings.
- Calories represent the main daily completion state.
- Macros shape creature categories and bonuses.
- Logging and goal completion earn currency.
- Currency upgrades an isometric base.
- Widgets show progress or a static base snapshot.

## Current Architecture

- `Sources/MacroMonstersCore`: portable product logic for nutrition totals, goal evaluation, rewards, upgrades, creature events, and widget snapshots.
- `Sources/MacroMonstersApp`: SwiftUI app shell, SwiftData models, food search service, SpriteKit base scene, and app views.
- `Sources/MacroMonstersWidgets`: WidgetKit progress and base widgets.
- `Tests/MacroMonstersCoreTests`: unit tests for core logic.
- `Tests/MacroMonstersUITests`: UI tests for onboarding, manual food logging, food search logging, and upgrades.
- `project.yml`: XcodeGen project definition and shared scheme configuration.
- `Package.swift`: Swift package definition for pure core library tests.

## Verified Commands

Use the iPhone 17 simulator id to avoid destination wrapping or naming mistakes:

```sh
SWIFTPM_HOME="$PWD/.build/swiftpm-home" CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-module-cache" swift test
```

```sh
xcodebuild build \
  -project MacroMonsters.xcodeproj \
  -scheme MacroMonsters \
  -destination 'id=5CC012F4-2DB0-4725-B435-69B851D7746D'
```

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

## Latest Validation Results

- Food search and API reliability slice completed on May 30, 2026.
- `swift test`: 13 tests, 0 failures.
- `xcodebuild build -scheme MacroMonsters`: build succeeded.
- `xcodebuild test -scheme MacroMonstersCore`: 8 tests, 0 failures.
- `xcodebuild test -scheme MacroMonsters`: 4 UI tests, 0 failures.

## Notes For Signing And Widgets

The same app group must stay present in:

- `project.yml`
- `Sources/MacroMonstersApp/Supporting/MacroMonsters.entitlements`
- `Sources/MacroMonstersWidgets/MacroMonstersWidgets.entitlements`
- `Sources/MacroMonstersCore/WidgetSnapshot.swift`

Identifiers currently used:

- `com.sxxie.MacroMonsters`
- `com.sxxie.MacroMonsters.widgets`
- `group.com.sxxie.macromonsters`

## USDA Food Search

`FDC_API_KEY` is optional for local development. Without it, the app uses local sample foods plus manual entry. The Log Food screen labels whether it is using sample foods or USDA search.

To enable USDA FoodData Central search:

1. Open `MacroMonsters.xcodeproj` in Xcode.
2. Select the `MacroMonsters` project and then the `MacroMonsters` app target.
3. Open Build Settings.
4. Add a user-defined setting named `FDC_API_KEY`.
5. Set it to the USDA FoodData Central API key for the active configuration.

Empty searches show sample foods. API errors are non-blocking and keep manual entry available.

The next recommended implementation slice is Logging flow UX.

## End Of Slice Checklist

Before ending each future development slice:

- Run the relevant tests listed above.
- Update `DEVELOPMENT_PLAN.md` task status and next recommendation.
- Update this handoff if commands, simulator ids, architecture, app groups, or setup steps changed.
- Commit one coherent slice with a concise message.
