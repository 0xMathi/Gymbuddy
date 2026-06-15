# GymBuddy — TestFlight & App Store submission checklist

Status as of launch-prep. ✅ = done in the repo · ⬜ = you do it (needs your Apple Developer account).

## 0. Pre-flight (code) — ✅ done
- ✅ Generic starter plans, onboarding, kg/lb, EN/DE localization
- ✅ Fully offline (no network), no tracking, microphone permission removed
- ✅ Version **1.0**, build **1**, bundle id `com.mathis.GymBuddy`
- ✅ App icon (1024×1024) present and on-brand
- ✅ Dead `DesignLab/` code removed
- ✅ Listing copy (`docs/app-store-listing.md`) + screenshots (`docs/app-store/en` & `/de`)
- ✅ Privacy policy page (`docs/privacy/`)

## 1. Host the privacy policy — ⬜
- GitHub → repo **Settings → Pages** → Source: **main**, folder **/docs** → Save
- Replace both `REPLACE-WITH-YOUR-SUPPORT-EMAIL` placeholders in `docs/privacy/index.html`
- Confirm live: **https://0xmathi.github.io/Gymbuddy/privacy/**

## 2. Apple Developer / App Store Connect setup — ⬜
- Enrolled in the **Apple Developer Program** ($99/yr)
- App Store Connect → **My Apps → +** → New App
  - Platform iOS · Name: **GymBuddy** (check availability — see note) · Primary language **English (U.S.)**
  - Bundle ID: `com.mathis.GymBuddy` · SKU: e.g. `gymbuddy-001`
- ⚠️ **Name availability:** if "GymBuddy" is taken, the *display name* can differ from the listing;
  fallbacks in `docs/app-store-listing.md`.

## 3. Build & upload — ⬜ (Xcode, your signing)
- Xcode → select **Any iOS Device** → **Product → Archive**
- Organizer → **Distribute App → App Store Connect → Upload** (Xcode auto-manages signing)
- Wait for the build to finish "Processing" in App Store Connect (~5–30 min)

## 4. TestFlight (your friends first) — ⬜
- App Store Connect → **TestFlight** → fill **Test Information** (the offline app needs no demo account)
- **Internal testing:** add your own Apple ID, install via the TestFlight app to smoke-test
- **External testing:** create a group → add friends by email → submit the build for a quick
  TestFlight beta review (usually <1 day) → share the public link

## 4b. In-App Purchases — Tip Jar — ⬜ (App Store Connect)
The app has a voluntary tip jar (Settings → "Support GymBuddy"). Create 3 **Consumable** IAPs
with these exact product IDs (must match the code), set prices, and submit them **with the build**:

| Product ID | Type | Price | Reference name |
|-----------|------|-------|----------------|
| `com.mathis.GymBuddy.tip.preworkout` | Consumable | ~€1.99 | Pre-Workout Tip |
| `com.mathis.GymBuddy.tip.proteinshake` | Consumable | ~€4.99 | Protein Shake Tip |
| `com.mathis.GymBuddy.tip.cheatmeal` | Consumable | ~€9.99 | Cheat Meal Tip |

- Each needs a display name + description + a review screenshot (a shot of the tip jar screen works;
  see `docs/app-store/` style).
- **Test locally first:** Xcode → Edit Scheme → Run → Options → **StoreKit Configuration** →
  `GymBuddy/Models/GymBuddy.storekit`, then run — the tip sheet and purchase flow work in the simulator.
- Sandbox: also testable via a Sandbox Apple ID once the IAPs exist in ASC.

## 5. App Store listing — ⬜ (paste from `docs/app-store-listing.md`)
- **Name:** GymBuddy: Workout Tracker · **Subtitle:** Lifting log, sets & rest timer
- **Keywords:** the 99-byte string (EN), plus the German set under the German localization
- **Description** + **Promotional text** (EN and DE)
- **Screenshots:** upload `docs/app-store/en/01…06` to the 6.9" slot (EN), `docs/app-store/de/01…06` under German
- **Category:** Health & Fitness · **Price:** Free
- **Privacy Policy URL:** the GitHub Pages link from step 1
- **App Privacy:** answer **"No, we do not collect data"** → "Data Not Collected" (see `docs/app-store-privacy.md`)
- **Age rating:** answer all "None" → 4+

## 6. Submit for review — ⬜
- Attach the processed build → **Add for Review → Submit**
- Review usually takes 24–48h. The "no account, fully offline" nature makes for a clean review.

## After launch (planned)
- v1.0: optional Tip-Jar IAP to recoup the fee
- v1.1: **GymBuddy Pro** (iCloud sync + charts/PRs + unlimited plans) as a one-time unlock → second launch moment
- Marketing: r/iOSApps, r/fitness, optional Product Hunt
