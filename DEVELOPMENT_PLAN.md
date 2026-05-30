# Macro Monsters Development Plan

This is the living roadmap for continuing Macro Monsters across Codex chats.

## Current Status

- Native iOS MVP builds and tests on the iPhone 17 simulator.
- Core loop exists: onboarding goals, food logging, macro totals, rewards, creatures, base upgrades, and widgets.
- Prototype feedback has been captured and split into near-term implementation slices and later refinements.

## Product Pillars

- Macro tracking should be quick, clear, and reliable.
- Nourishlings should make nutrition progress feel alive without obscuring the tracker.
- Currency and upgrades should reward consistent logging and goal completion.
- Widgets should show useful passive progress snapshots.

## Backlog

### Now

1. Food search and API reliability.
   - Confirm `FDC_API_KEY` setup through Xcode build settings.
   - Add clear loading, empty, and error states for food search.
   - Keep local sample foods and manual entry as reliable fallbacks.
   - Add tests for API fallback behavior where practical.

2. Logging flow UX.
   - Move logging from a full tab to a primary action button.
   - Keep the main navigation focused on Today, Base, Upgrades, and Settings.
   - Preserve UI test coverage for food search logging and manual logging.

3. Settings foundation.
   - Add a Settings view for app preferences.
   - Add theme selection with System, Light, and Dark modes.
   - Store the preference locally with SwiftData or app storage, whichever best matches the existing app structure.

### Next

4. First-run tutorial.
   - Explain goals, logging, Nourishlings, currency, base upgrades, and widgets.
   - Keep the tutorial skippable and short.
   - Add a way to replay it from Settings.

5. Macro goal setup refinement.
   - Improve the onboarding goal form beyond raw numeric fields.
   - Consider simple presets and guidance without turning onboarding into a long calculator.
   - Keep manual override available.

6. Currency naming.
   - Replace generic "Currency" display text with a unique in-world name.
   - Keep model and API names stable until the product name is chosen, unless the rename becomes worth a core type migration.

### Later

7. Deeper Nourishling progression.
   - Make creature changes more visible after logging.
   - Improve how macro categories map to creature events and base activity.

8. Base and widget polish.
   - Improve SpriteKit base readability.
   - Check widget layouts manually in small and medium families.

## Continuation Workflow

Start each new Codex chat with:

```text
Read CODEX_HANDOFF.md and DEVELOPMENT_PLAN.md first. Continue from the highest-priority incomplete item unless I give a more specific task.
```

End each development slice by updating:

- Completed work.
- Commands run and results.
- New decisions or blockers.
- Recommended next task.

Commit after each coherent slice, not after every small edit.

## Standard Verification

Use the iPhone 17 simulator id to avoid command wrapping issues:

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

## Latest Slice Notes

- First Xcode validation pass completed.
- Build and test configuration was corrected.
- Current recommended next implementation slice: Food search and API reliability.
