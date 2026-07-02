# GymBuddy — App Store Listing (ASO)

Challenger-tier optimization: every character earns its place. Apple indexes
**Title + Subtitle + Keyword field** (each word once, never repeated across them);
the description is **not** indexed (pure conversion). Screenshot captions ARE indexed (since 2025).

---

## 🇬🇧 English (primary)

### App Name — 30 char limit
> **GymBuddy: Workout Log** — `21 chars`

Brand + high-volume keywords ("workout", "log"). Chosen because "GymBuddy: Workout Tracker"
was already taken in App Store Connect (also-free alternative: `GymBuddy: Lifting Tracker`).

### Subtitle — 30 char limit
> **Lifting tracker, sets & timer** — `29 chars`

Adds new keywords (lifting, tracker, sets, timer) — none repeated from the title.
("Tracker" recovered here since the title dropped it; "log" not repeated since the title now owns it.)

### Keyword field — 100 byte limit (commas, no spaces)
> `strength,training,gym,weight,exercise,planner,routine,reps,bodybuilding,powerlifting,push,pull,legs` — `99 bytes`

No word repeats the title/subtitle. Covers strength/PPL/bodybuilding search intent.

### Description (conversion only — not indexed)
```
Your plan. Every set. Tracked.

GymBuddy is a fast, focused workout tracker for people who actually lift.
No subscription, no account, no noise — just you and the gym.

• Push / Pull / Legs plans, ready to go — or build your own
• Log sets, reps & weight in one tap
• See exactly what you lifted last time, on every set
• Built-in rest timer with lock-screen alerts
• Supersets, custom rest, kg or lb
• 100% offline — your data never leaves your phone

No ads. No sign-up. No monthly fee. Open the app, pick a plan, train.

Made for the gym.
```

### Promotional text — 170 char limit (updatable, not indexed)
> **A fast, focused lifting tracker that remembers what you did last time — Push/Pull/Legs plans ready to go, rest timer built in. No account, no ads.** — `147 chars`

*(2.3.7: price wording like "free" / "no subscription" stays OUT of screenshots and promo text — the description is the allowed place for it.)*

---

## 🇩🇪 Deutsch

### App-Name — 30 Zeichen
> **GymBuddy: Trainings-Tracker** — `27 Zeichen`

### Untertitel — 30 Zeichen
> **Sätze, Gewichte & Pausen-Timer** — `30 Zeichen`

### Keyword-Feld — 100 Bytes (Kommas, keine Leerzeichen, keine Umlaute = bytesparend)
> `krafttraining,hanteltraining,trainingsplan,fitnessstudio,muskelaufbau,gym,wiederholungen,langhantel` — `99 bytes`

### Beschreibung
```
Dein Plan. Jeder Satz. Getrackt.

GymBuddy ist ein schneller, fokussierter Workout-Tracker für alle, die wirklich trainieren.
Kein Abo, kein Account, kein Lärm — nur du und das Gym.

• Push / Pull / Legs sofort startklar — oder bau eigene Pläne
• Sätze, Wiederholungen & Gewicht mit einem Tap loggen
• Sieh bei jedem Satz, was du letztes Mal geschafft hast
• Eingebauter Pausen-Timer mit Lockscreen-Hinweis
• Supersätze, individuelle Pausen, kg oder lb
• 100% offline — deine Daten verlassen nie dein Handy

Keine Werbung. Keine Anmeldung. Keine Monatsgebühr. App auf, Plan wählen, trainieren.

Gebaut fürs Gym.
```

### Promo-Text — 170 Zeichen
> **Ein schneller Trainings-Tracker, der sich merkt, was du letztes Mal geschafft hast — Push/Pull/Legs startklar, Pausen-Timer eingebaut. Kein Account, keine Werbung.** — `163 Zeichen`

---

## Category & metadata
- **Primary category:** Health & Fitness
- **Secondary:** (optional) Sports
- **Age rating:** 4+
- **Price:** Free
- **Localizations:** English, German

## Screenshots — final EN set (`docs/app-store/en/`, 1290×2796, indexed captions)
Rebuilt 02.07.2026 after the 2.3.7 rejection (no price references in screenshots).
1. `01-log-every-set` — "Log every set in seconds." (workout, Bench Press 8 × 155 lb)
2. `02-your-plans` — "Your plans, ready to go." (start screen)
3. `03-no-account` — "No account. No ads. No nonsense." (statement — replaces the rejected
   "No subscription… / Free forever" slide; in the top 3 because it is the key differentiator)
4. `04-rest-timer` — "A rest timer that finds you." (rest timer)
5. `05-last-time` — "See what you lifted last time." (workout with "LAST TIME · 155 LB × 8"
   ghost value — replaces the former slot-6 duplicate of the start screen)
6. `06-just-you` — "Just you and the gym." (brand hero)

German set (`docs/app-store/de/`, kg): same order — `03-kein-account` ("Kein Account. Keine
Werbung. Kein Quatsch."), `05-letztes-mal` ("Du siehst immer, was letztes Mal ging.").
Retired slides live in `docs/app-store/retired/`. Generator: scratchpad `make_slides.py`
(headless Chrome, 1290×2796) — raw device shots from iPhone 17 Pro simulator, status bar 17:21.

App Store Connect required size is **6.9" (1290×2796)** — a single set is accepted and
auto-scaled to smaller devices.

---

*What can't be assessed without paid ASO tools: exact keyword search volumes & rankings.
The keyword choices above target intent-rich, mid-competition terms typical for gym loggers.*
