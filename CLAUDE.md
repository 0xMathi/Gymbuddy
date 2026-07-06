# GymBuddy — Projekt-Anweisungen

iOS-Workout-Tracker (SwiftUI + SwiftData, iOS 17+, iPhone-only, Dark-only).
Solo-Projekt von Matti. Live im App Store (Apple-ID 6784635713, `com.mathis.GymBuddy`).

## Typografie & Copy (hart)

- **Immer Halbgeviertstrich „–", niemals Geviertstrich „—"** in jeder User-Copy
  (App-Strings EN+DE, Store-Texte, What's New). Einzige Ausnahme: „—" als
  Leerwert-Platzhalter („8 × —"). Vor Commits: auf „—" greppen.
- Brand-Statements bleiben Englisch, auch in der DE-UI („TIME TO WORK.", „NEXT UP").
- Marken-Versprechen, das kein Feature aufweichen darf: 100 % offline, kein Account,
  keine Werbung, kein Abo (Tip Jar ist die einzige Monetarisierung).

## Architektur-Fixpunkte

- **Lokalisierung:** Runtime-`L`-Enum in `GymBuddy/Models/Strings.swift` + `ExerciseLocalization`
  (KEIN String Catalog). Einzige Sprachquelle: `AppSettings.shared.resolvedLanguageIsGerman`
  (berücksichtigt den In-App-Sprachschalter). Neue Strings immer EN+DE als `t(en, de)`.
- **Live Activity** (`GymBuddyWidgets`-Target): Alle Texte kommen FERTIG LOKALISIERT über
  `RestActivityAttributes`/ContentState aus der App — die Extension kennt `L` nicht.
  Skip-Button = `LiveActivityIntent` → `WorkoutSessionManager.shared` (Singleton).
  Countdown rendert das System via `Text(timerInterval:)`; App pusht nur Übergänge.
- **Gewichte:** Speicherung immer kg; Anzeige/Format zentral über `WeightDisplay` und
  `WeightUnit` (`pickerStep` 1,25 kg fürs Wheel, `step` 2,5 kg für Quick-Buttons,
  `wheelOptions(including:)` damit Off-Grid-Werte das Wheel nicht brechen).
- `Theme.swift` ist in App UND Widget-Target (Farben: bg #0A0A0B, accent #FF4F00).

## Verifikations-Standard

Jede UI-Änderung vor dem Commit im Simulator ansehen:
`xcodebuild -scheme GymBuddy -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
→ `xcrun simctl install/launch` → per Bildschirmsteuerung durchklicken.
Persönlicher Skill `ios-sim-verify` beschreibt den Workflow inkl. Fallen.

**Aufräum-Pflicht:** Das Edit-Sheet schreibt in die PLAN-Daten. Nach Tests mit geänderten
Werten den Originalwert wiederherstellen und Test-Workouts VERWERFEN (nicht speichern),
sonst landet Müll in Mattis echten Plänen/History.

## Store-Assets

- Slides: `scripts/make_store_slides.py [all|ghost|lockscreen]` (headless Chrome, 1290×2796).
  Sets: `docs/app-store/en|de/`, ausgemusterte nach `retired/`, Geräte-Rohshots nach `raw/`.
- Der Simulator-Lockscreen rendert tickende Live-Activity-Timer als „1:--" —
  Lockscreen-Motive entweder vom echten Gerät oder als stilisiertes Composing (lockscreen-Modus).
- App-Icon: 1024×1024 ohne Alpha, gleiche Chrome-Pipeline; Datei ersetzt
  `Assets.xcassets/AppIcon.appiconset/GymBuddy_AppIcon_1024x1024.png` (Name beibehalten).
- Übungs-/Plan-Bilder: gpt-image-1 via `scripts/generate_exercise_images.py` (Key in `.env.local`).

## Releases

ASO-Texte und What's New leben in `docs/app-store-listing.md` — ASC spiegelt dieses Doc,
Änderungen immer an beiden Stellen. Release-Ablauf (Version-Bump in ALLEN Targets,
ASC-Browser-Flow, Screenshot-Tausch, Build, Submit): persönlicher Skill `asc-release-via-browser`.
Roadmap + Erledigt-Stand: `docs/ROADMAP.md` (✅-Marker mit Datum pflegen).

## Arbeitsweise mit Matti

- Antworten deutsch, kurz; Code/Kommentare englisch. Kein Terminal-Profi: Anleitungen
  Schritt für Schritt, NIEMALS Platzhalter in Befehlen (werden 1:1 kopiert).
- Xcode-Archive/-Upload und Datei-Drag&Drops macht Matti selbst (mit Anleitung);
  Finanz-/Steuer-/Konto-Daten füllt er immer selbst aus.
- Commits: englisch, thematisch gebündelt, mit „Verified in simulator:"-Zeile wenn zutreffend,
  `Co-Authored-By: Claude`. Lokal committen ist etablierter Workflow; push nur auf Zuruf.
