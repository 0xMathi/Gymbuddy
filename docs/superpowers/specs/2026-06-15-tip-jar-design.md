# GymBuddy — Tip Jar (design spec)

**Date:** 2026-06-15 · **Status:** approved (concept)

## Overview
A purely voluntary "Support GymBuddy" tip jar. Nothing is unlocked, no ads, no account —
goodwill only. Lets fans tip €1.99–9.99 to help recoup the Apple Developer fee. Honors the
app's "no subscription, no account" ethos.

## Products (StoreKit 2, **consumable** — tip as often as you like)
| Tier | Product ID | Price tier (EUR) | Display name |
|------|-----------|------------------|--------------|
| 1 | `com.mathis.GymBuddy.tip.preworkout` | ~1,99 € | Pre-Workout |
| 2 | `com.mathis.GymBuddy.tip.proteinshake` | ~4,99 € | Protein Shake |
| 3 | `com.mathis.GymBuddy.tip.cheatmeal` | ~9,99 € | Cheat Meal |

Consumable → repurchasable, no entitlement to persist, no "restore" needed.

## Architecture (small, isolated units)
- **`TipJarStore`** (`@Observable`, `Services/`): loads products via `Product.products(for:)`,
  `purchase(_:)`, listens for transaction updates, finishes transactions. State enum:
  `loading | loaded([Product]) | failed`. Plus `isPurchasing`, `didThankYou`.
  - Tip is a consumable: on a verified successful transaction → set `didThankYou = true`,
    `await transaction.finish()`. No unlock stored.
- **`TipJarView`** (`Views/`): the 3 themed tier cards (app-defined names + subtitle), price from
  `product.displayPrice` when loaded (locale-correct), tap → `store.purchase(product)`.
  Thank-you state reuses the existing `ConfettiView` + a warm line. Dark/orange V1 styling.
- **Settings entry:** a "Support GymBuddy" row → presents `TipJarView` as a sheet.

## States & UX
- Loading: subtle spinner.
- Loaded: 3 cards with localized prices, one primary feel; a short heartfelt intro line.
- Purchasing: button shows progress, disabled.
- Success: confetti + "Thank you — seriously." → dismiss.
- User cancel / failure: silently return to the cards (no scary error).
- If products can't load (e.g. offline, or not yet created in ASC): cards show fallback price
  text and a gentle "Tips unavailable right now" note; buttons disabled.

## Testing
- Add `GymBuddy.storekit` config (the 3 consumables) + a **shared scheme** referencing it, so the
  full purchase flow runs in the simulator via Xcode (Run) and in sandbox. Design/layout verified
  via the running app (fallback prices when StoreKit test env not injected).

## Localization (EN/DE via `L`)
Intro line, thank-you line, "Support GymBuddy" row, tier subtitles, unavailable note.

## App Store Connect (manual, documented)
Create the 3 consumable IAPs with the product IDs above, set prices, add to the app, submit with
the binary. Documented in the submission checklist.

## Out of scope (later)
History/charts/PRs, "GymBuddy Pro" one-time unlock, persisting tip count, restore.
