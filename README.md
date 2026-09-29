# Legendary Vibez — iOS (Phase 1 MVP)

Pass-the-phone party game. SwiftUI, iOS 17+, no backend.

## Open it in Xcode

This folder already contains `LegendaryVibez.xcodeproj` (Xcode 26 project, iOS 17.0 target, bundle id `HashtagCinema.LegendaryVibez`). The `LegendaryVibez/` folder is a synchronized group, so every file in it is in the target automatically.

1. Double-click `LegendaryVibez.xcodeproj`.
2. Signing & Capabilities → pick your Team.
3. Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration → `Products.storekit` (File → Add Files first if it isn't listed).
4. Pick an iPhone simulator, press Run.

## Status

This code was written without a compiler. Expect a handful of trivial compile fixes on first build (SwiftUI API drift, a missing `import`). Hand the whole folder plus the build spec to Claude Code with: "Open this in Xcode, fix any compile errors, run it in the simulator, and walk me through a full game." That is the fastest path to day 1.

## What's built

- Age gate (21+, drink-responsibly copy), persisted with `@AppStorage`
- Home, How to Play, Player Setup (names, seating order, heat dial, drink mode, deck size)
- Game loop: Pass screen → Card → Done / Drink → next player
- Placeholder resolution: `{left}`, `{right}`, `{random}`, `{chosen}`, `{shot}`, `{shots}`
- Escalation shuffle (warm-up cards first, heat 3 pushed out of the opening ten, Power cards scattered late)
- Mechanics: countdown timer, phone timer, freeze buzzer, spin the bottle, rock-paper-scissors, roster picker
- Rate-everyone sheet (swipe roster with 1–10 sliders)
- Power card hand (Keep / Play later)
- Card flip animation, progress bar, per-player drink/done/skipped tallies on the pass screen
- Drag-to-reorder seating
- End screen with five awards, "Play Again", and a story-sized shareable awards image (ShareLink)
- Session persistence (survives a phone call or app switch)
- **Sound design** (7 synthesized placeholder SFX in `Resources/Sounds`; swap for real ones, same filenames) with a mute toggle
- **Vote cards** (6th card type): 3-2-1 countdown, everybody points, tap the loser, they drink
- **Card stats + Best Card Tonight**: every card logs shown/done/skipped on device; awards screen asks the group to pick the night's best card. `CardStats.shared.csv()` exports it. This decides what goes in After Dark.
- **App Store review prompt** after the second completed game
- **StoreKit 2** with one non-consumable, `com.legendaryvibez.fulldeck` ($4.99). Free tier = Chill heat + Quick deck. `Products.storekit` included for local testing (Xcode → scheme → Options → StoreKit Configuration).
- Placeholder app icon (swap in the client's logo art before submission)

## StoreKit setup (day 9, App Store Connect)
1. App Store Connect → your app → In-App Purchases → create Non-Consumable, Product ID exactly `com.legendaryvibez.fulldeck`, price tier $4.99.
2. Add a screenshot of the paywall for review, submit the IAP with the app binary.
3. To bypass the paywall while developing, set `debugUnlockAll = true` in `StoreManager.swift`. Never ship it true.

## Phase 2 backlog (not yet built)
- Pack store: After Dark / Couples / Bachelorette / Pregame as additional products
- Custom card creator
- Sound design
- Final icon + App Store screenshots from the client's art

## Adding a pack
Drop `<pack_id>_deck.json` into `Resources/`, add the id to the `packs` init list in `AppStore.swift`.
Card schema is documented in the build spec.

## App Review notes
- Set age rating 17+ in App Store Connect (Sexual Content & Nudity: Frequent/Intense; Alcohol: Frequent/Intense; Profanity: Frequent/Intense).
- Default drink mode is **Sips**, so the reviewer's first run never says "shot".
- Default heat is **Spicy** (heat ≤ 2). Consider defaulting to **Chill** for the submission build.
