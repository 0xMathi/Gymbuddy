# App Store Connect — Privacy setup (GymBuddy)

Everything Apple needs for the privacy side of the submission. GymBuddy is fully offline
(no network calls, no accounts, no analytics), so this is the simplest possible case.

## 1. App Privacy "Nutrition Label" answers

In **App Store Connect → your app → App Privacy**, answer the questionnaire:

> **"Do you or your third-party partners collect data from this app?"**
> → **No**

That single answer produces the **"Data Not Collected"** label on your App Store page.
Nothing else needs to be configured. (Reason it's accurate: all workout data lives in the
on-device SwiftData store, the app makes zero network requests, and there are no analytics
or advertising SDKs.)

If Apple asks follow-ups, the truthful answers are:
- **Tracking** (ATT): No — the app does not track users. No `NSUserTrackingUsageDescription` needed.
- **Third-party SDKs:** None.
- **Account required:** No.

## 2. Privacy Policy URL (required)

Apple requires a reachable privacy-policy URL. One is ready at
[`docs/privacy/index.html`](privacy/index.html). Host it free via **GitHub Pages**:

1. Push this repo to GitHub (already at `github.com/0xMathi/Gymbuddy`).
2. On GitHub: **Settings → Pages → Build and deployment**
   - Source: **Deploy from a branch**
   - Branch: **main**, folder: **/docs**, then **Save**.
3. After ~1 minute the policy is live at:
   **https://0xmathi.github.io/Gymbuddy/privacy/**
4. Paste that URL into App Store Connect:
   - **App Privacy → Privacy Policy URL**, and
   - **App Information → Privacy Policy URL** (per-localization if you list both languages).

> ⚠️ Before publishing: open `docs/privacy/index.html` and replace the two
> `REPLACE-WITH-YOUR-SUPPORT-EMAIL` placeholders with a real contact address
> (a dedicated alias like `gymbuddy@…` is nicer than your personal mail).

## 3. Permission strings (already in the app)

- **Notifications:** requested at runtime during onboarding (rationale shown first). No Info.plist string required.
- **Microphone:** none. The app only uses `AVAudioSession(.playback)` for the lock-screen rest timer,
  which needs no microphone permission. The leftover `NSMicrophoneUsageDescription` (from the removed
  voice feature) has been deleted from `Info.plist`.
- **Background audio:** `UIBackgroundModes = audio` is kept — it powers the lock-screen / Now-Playing
  rest timer.

## 4. Age rating

In the rating questionnaire everything is "None" → **4+**.

---

*Once Pages is live and the email placeholders are replaced, the privacy side of the submission is done.*
