# Legendary Vibez — iOS Build Spec v1

**Format:** Pass-the-phone party game. Local only. No accounts, no backend.
**Platform:** iOS 17+, iPhone only at launch. SwiftUI, StoreKit 2.
**Rating:** 17+. Age gate on first launch.

---

## 1. Screens

### 1.1 Launch / Age Gate
- Logo animation (red/black/gold, matches card art).
- "You must be 21+ to play. Drink responsibly." → Confirm button. Shown once, stored locally.

### 1.2 Home
- Play, Packs (store), Custom Cards, Settings, How to Play.

### 1.3 Player Setup
- Add 2–12 player names. Emoji avatar picker (optional).
- Reorder = seating order (clockwise). "Left" and "right" targeting derive from this.
- Heat dial: **Chill / Spicy / Legendary** (levels 1–3). Includes all cards ≤ selected level.
- Drink mode toggle: **Sips / Shots / No Alcohol** (No Alcohol swaps drink instructions for point penalties).
- Pack selector: checkboxes for owned packs.
- Deck size: Quick (30) / Full / Marathon (all owned packs).

### 1.4 Pass Screen
- Full-screen: "Pass to **[Name]**" with avatar. Tap to reveal card. Prevents peeking.

### 1.5 Card Screen
- Card rendered in the physical design (type badge, icon, text).
- Text is **resolved**: `{left}`, `{right}`, `{random}`, `{chosen}`, `{all}` replaced with real names.
- Buttons: **Done** / **Drink Instead** (records drink count, applies "2 drinks" default).
- Mechanic overlay when applicable (see §3).
- Power cards: **Use Now** or **Keep** (goes to player's hand).

### 1.6 Player Hand (Power cards)
- Small icon on the pass screen showing held Power cards. Tap to play at any time.

### 1.7 End Screen
- Awards: Biggest Freak (most Done on Legendary-level cards), Lightweight (most Drink Instead), Most Drinks, Power Player.
- Share card (image export) for Instagram/TikTok stories.
- Play Again (same players) / New Game.

### 1.8 Custom Cards
- Create card: type, text, heat level, targeting tags.
- Custom deck saved locally, selectable as a pack.

### 1.9 Store
- Pack grid with preview (3 sample cards each), price, Buy / Restore Purchases.

---

## 2. Card Data Model

Cards ship as JSON bundled in the app. One file per pack.

```json
{
  "pack_id": "base",
  "cards": [
    {
      "id": "base_dare_001",
      "type": "dare",            // truth | dare | act | drink | power | vote
      "text": "Kiss {left} on the neck",
      "heat": 2,                 // 1 chill, 2 spicy, 3 legendary
      "targets": ["left"],       // left | right | random | chosen | all | none
      "mechanic": "none",        // none | timer | spin | rps | freeze | phone_timer | rate_all | skip | vote
      "mechanic_value": null,    // e.g. 30 (seconds)
      "drink_alt": 2,            // drinks if skipped (default 2)
      "gender_filter": null      // null | "guys" | "ladies" (for "all the guys drink")
    }
  ]
}
```

### Base deck heat assignments (starting point — tune in TestFlight)
- **Heat 1:** most Truth, mild Drink ("if you're single," "missed a flight"), Power.
- **Heat 2:** most Dares, Act It Out, explicit-history Drink cards.
- **Heat 3:** naked lap, show nudes, demonstrate oral, body shots, ice-on-chest, "fuck the person who pulled this card."

Ship Heat 3 base cards inside the app but consider gating them behind the After Dark pack for review safety (see §6).

---

## 3. Mechanics

| Mechanic | Cards | Implementation |
|---|---|---|
| `timer` | Laugh 30s, orgy scene 10s | Countdown ring, haptic at end |
| `phone_timer` | Group goes through your phone 3 min | 3:00 countdown, "Give phone back" alert |
| `spin` | Spin the bottle | Animated bottle over player avatars in a circle; lands on a name |
| `rps` | Rock-paper-scissors | Tap-to-reveal for both players, app judges |
| `freeze` | Everybody freeze | Random 5–20s delay, then loud buzzer; first to move drinks |
| `chosen` | "Pick a player" | Player roster sheet, tap to select |
| `rate_all` | Rate everyone | Swipe roster with 1–10 sliders |

---

## 4. Game Flow Logic

1. Build deck from selected packs, filtered by heat ≤ setting.
2. Shuffle with **escalation weighting**: first third biased toward Truth/Drink, middle toward Dare/Act, Power cards spread across last two-thirds.
3. Turn order = seating order, clockwise.
4. Each turn: Pass screen → Card → resolve targets → mechanic (if any) → Done / Drink.
5. Power card "Keep" removes it from deck into the player's hand.
6. Game ends when deck is empty or user taps End Game.
7. Persist game state so an incoming call doesn't wipe the session.

---

## 5. Monetization (StoreKit 2)

| Product | Type | Price |
|---|---|---|
| Free | — | ~30 base cards, Heat 1–2 only |
| Full Base Deck | Non-consumable | $4.99 |
| After Dark (Heat 3 + new cards) | Non-consumable | $3.99 |
| Couples | Non-consumable | $2.99 |
| Bachelorette / Girls Night | Non-consumable | $2.99 |
| Pregame (fast, drink-heavy) | Non-consumable | $2.99 |
| Everything Bundle | Non-consumable | $14.99 |

- Restore Purchases button required by Apple.
- Store screen shows locked cards as blurred previews inside the game ("Unlock After Dark to see this one") — the strongest conversion moment is mid-game.
- Physical deck: QR code in box → promo code → unlocks Full Base Deck.

---

## 6. App Review Checklist

- [ ] 17+ age rating set in App Store Connect (Frequent/Intense: Sexual Content, Alcohol, Profanity).
- [ ] Age gate on launch.
- [ ] "Drink Responsibly" messaging on launch and in Settings.
- [ ] No-Alcohol mode exists and works.
- [ ] Default UI says "drinks," not "shots."
- [ ] Reviewer test path (free tier, Heat 1–2) contains no nudity/explicit-act cards.
- [ ] No images of nudity anywhere. Text only.
- [ ] Privacy policy URL (even with no data collection — required).
- [ ] Review App Review Guidelines 1.1 (Objectionable Content) and 1.4.3 (alcohol) the week of submission.
- [ ] Separate developer account/entity from Hashtag Cinema.

---

## 7. Timeline

Two-week MVP, then beta, then submit. Day-by-day in SPRINT_PLAN.md.

| Week | Milestone |
|---|---|
| 1 | Core loop, deck loaded, mechanics, heat + drink modes, persistence |
| 2 | Polish, edge cases, icon, App Store Connect listing, screenshots, internal TestFlight |
| 3 | Beta with client + 2–3 groups, tune deck, fix, submit for review |
| 4 | Review rounds (expect 1–2), launch |

---

## 8. v2 Backlog
- Remote rooms (room code, WebSocket) for FaceTime play
- Android
- Community card packs / voting
- Seasonal packs (Halloween, NYE, Spring Break)
- Apple Watch "you're up" buzz
