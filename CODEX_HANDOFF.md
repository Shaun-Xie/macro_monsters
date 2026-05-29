# Codex Handoff: Macro Monsters

Use this file as the first context document for continuing development on a Mac.

## Current Repository State

- Repository: `https://github.com/Shaun-Xie/macro_monsters`
- Latest known commit: `af94277 feat: scaffold Macro Monsters iOS MVP`
- Primary target: polished native iOS release
- Current direction: native SwiftUI/SpriteKit/WidgetKit app, not a PWA

## Continuation Prompt For Codex CLI

Paste this into Codex CLI from the repository root on the Mac:

```text
Continue development on Macro Monsters.

Context:
- This is a native iOS app MVP, not a PWA.
- Stack: SwiftUI app, SwiftData local persistence, SpriteKit fixed-isometric base scene, WidgetKit widgets, MacroMonstersCore Swift package for testable product logic.
- Latest implemented commit: af94277 feat: scaffold Macro Monsters iOS MVP.
- Read README.md, CODEX_HANDOFF.md, project.yml, Package.swift, Sources/, and Tests/ before editing.
- First task: generate the Xcode project with XcodeGen, build in Xcode/xcodebuild, fix compile errors, run core tests, then run app/unit/UI tests where possible.
- Preserve the current product direction: calorie/macro tracking, Nourishling creature loop, currency rewards, base upgrades, progress widget, base widget.
```

## Mac Setup Checklist

1. Update macOS.
2. Install Xcode from the Mac App Store or Apple Developer.
3. Open Xcode once so it installs required platform components.
4. Install Command Line Tools if needed:

   ```sh
   xcode-select --install
   ```

5. Point CLI tooling at full Xcode:

   ```sh
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   xcodebuild -version
   ```

6. Install Homebrew from `https://brew.sh`.
7. Install project tooling:

   ```sh
   brew install git xcodegen
   ```

8. Install Codex CLI if desired:

   ```sh
   npm install -g @openai/codex
   codex --login
   ```

## Clone And Run

Clone the repo:

```sh
git clone https://github.com/Shaun-Xie/macro_monsters.git
cd macro_monsters
```

Generate the Xcode project:

```sh
xcodegen generate
open MacroMonsters.xcodeproj
```

In Xcode:

- Select the `MacroMonsters` scheme.
- Pick an iOS 17+ simulator.
- Run the app.
- Use Product > Test for tests.

Useful CLI checks:

```sh
swift test
xcodegen generate
xcodebuild test -scheme MacroMonsters -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Expected First Development Task

The scaffold was created in WSL where `swift`, `xcodebuild`, and `xcodegen` were unavailable, so the first Mac task should be:

1. Generate the Xcode project.
2. Build the app.
3. Fix any compile errors from SwiftUI, SwiftData, SpriteKit, WidgetKit, target configuration, signing, or app group setup.
4. Run `MacroMonstersCoreTests`.
5. Run the app on an iOS simulator.
6. Run UI tests where feasible.

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
- `Tests/MacroMonstersUITests`: UI test skeleton for onboarding, manual food logging, food search logging, and upgrades.
- `project.yml`: XcodeGen project definition.
- `Package.swift`: Swift package definition for the core library and tests.

## Notes For Signing And Widgets

If Xcode reports signing or app group issues, update these identifiers to match the Apple Developer account/team:

- `com.sxxie.MacroMonsters`
- `com.sxxie.MacroMonsters.widgets`
- `group.com.sxxie.macromonsters`

The same app group must be present in:

- `project.yml`
- `Sources/MacroMonstersApp/Supporting/MacroMonsters.entitlements`
- `Sources/MacroMonstersWidgets/MacroMonstersWidgets.entitlements`
- `Sources/MacroMonstersCore/WidgetSnapshot.swift`

## USDA Food Search

`FDC_API_KEY` is optional for local development. Without it, the app should use local sample foods plus manual entry.

To enable USDA FoodData Central search, add `FDC_API_KEY` as an Xcode build setting for the app target.

## Mac Hygiene

For a clean developer machine:

- Prefer a fresh macOS install or Erase All Content and Settings if the Mac has unwanted previous setup and no needed files.
- Avoid third-party cleaner apps.
- Keep installed tools minimal: Xcode, Homebrew, Git, XcodeGen, editor, Codex CLI.
- Do not install Android Studio, Flutter, Node frameworks, or extra runtimes unless the project needs them.
- Periodically remove unavailable simulator runtimes:

  ```sh
  xcrun simctl delete unavailable
  ```

- Periodically clean Homebrew caches:

  ```sh
  brew cleanup
  ```
