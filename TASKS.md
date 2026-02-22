# GymBuddy – UX/UI Improvement Tasks

> **Für Opus:** Arbeite die Tasks sequenziell ab. Jeder Task ist self-contained mit exakten Datei-Pfaden, konkreten Anforderungen und Akzeptanzkriterien. Lies immer erst die relevante(n) Datei(en), bevor du Änderungen machst. Committe nach jeder abgeschlossenen Phase.

---

## Architektur-Referenz

```
GymBuddy/
├── Models/
│   ├── WorkoutPlan.swift          – SwiftData: @Model, hat .lastUsedAt (nach Task 1.1 hinzufügen)
│   ├── WorkoutSession.swift       – Struct (ephemeral, nicht persistent)
│   └── WorkoutPlanSeed.swift      – Seeding-Logik für Default-Pläne
├── ViewModels/
│   └── WorkoutSessionManager.swift – @Observable, zentrale Session-Logik
├── Views/
│   ├── StartScreenView.swift      – Home, Plan-Cards, Hero-Typografie
│   ├── Plans/
│   │   └── PlanEditView.swift     – Plan bearbeiten, ExerciseDetailSheet (Weight-Picker)
│   └── Workout/
│       ├── ActiveWorkoutView.swift    – Aktives Training
│       ├── WorkoutSummaryView.swift   – Post-Workout Screen
│       └── RestTimerView.swift        – Rest Timer Overlay
└── Theme.swift                    – Design System (Colors, Fonts, Spacing)
```

**Key Conventions:**
- SwiftUI Observation: `@Observable` + `@Bindable` (kein `ObservableObject`)
- SwiftData: `@Model` für Persistenz, `@Environment(\.modelContext)` für Zugriff
- Kein `head`/`tail` in Shell – Read-Tool mit `limit`/`offset` verwenden
- Kommentare auf Englisch, Variablennamen auf Englisch
- `Theme.Colors`, `Theme.Fonts`, `Theme.Spacing` für alle Styling-Entscheidungen

---

## Phase 1 – Quick Wins (klein, hoher Impact)

### Task 1.1 – "END"-Button: Confirmation vor Workout-Abbruch

**Problem:** `manager.cancelWorkout()` in `ActiveWorkoutView.swift:95` wird sofort ausgeführt – kein Schutz vor versehentlichem Tap.

**Dateien:** `GymBuddy/Views/Workout/ActiveWorkoutView.swift`

**Was tun:**
1. State-Variable hinzufügen: `@State private var showCancelConfirmation = false`
2. Den END-Button so ändern, dass er `showCancelConfirmation = true` setzt statt direkt `manager.cancelWorkout()` aufzurufen
3. `.confirmationDialog` an den ZStack hängen:
   - Titel: `"End Workout?"`
   - Message: `"Your progress will be lost."`
   - Destructive Button: `"End Workout"` → ruft `manager.cancelWorkout()` auf
   - Cancel Button: Standard iOS Cancel

**Akzeptanzkriterium:** Tap auf END zeigt Dialog. Nur "End Workout" im Dialog bricht ab. Cancel schließt Dialog ohne Aktion.

---

### Task 1.2 – Übungs-Fortschritt im ActiveWorkoutView

**Problem:** User sieht nur Set-Fortschritt der aktuellen Übung, nicht wo sie im Gesamtworkout sind (z.B. "Übung 3 von 6").

**Dateien:** `GymBuddy/Views/Workout/ActiveWorkoutView.swift`

**Was tun:**
1. Im Header-Bereich (VStack, Zeile ~20), **oberhalb** des Übungsnamens, eine neue Zeile einfügen:
   ```
   EXERCISE 3 / 6
   ```
2. Die Werte aus `session.currentExerciseIndex` (0-basiert → +1 für Anzeige) und `session.plan.exercises.count` lesen
3. Styling: `Theme.Fonts.label`, `tracking: 3`, Farbe `Theme.Colors.textSecondary`
4. Zusätzlich: Eine schmale Progress-Bar (Höhe 2px, accent-farbig) direkt unter diesem Label, die den Fortschritt zeigt (currentExerciseIndex+1 / total)

**Akzeptanzkriterium:** Beim aktiven Workout ist oben sichtbar welche Übungsnummer gerade aktiv ist und wie viele insgesamt. Progress-Bar füllt sich pro Übung.

---

### Task 1.3 – Rest Timer: "TAP TO SKIP" Hint

**Problem:** Skip-Funktionalität existiert (Skip-Button), aber User wissen nicht dass der Timer interaktiv ist.

**Dateien:** `GymBuddy/Views/Workout/RestTimerView.swift`

**Was tun:**
1. Datei lesen und verstehen
2. Einen pulsierenden Hinweis-Text `"TAP TO SKIP"` zur View hinzufügen:
   - Position: unten, oberhalb des Skip-Buttons (falls vorhanden) oder am unteren Rand
   - Font: `Theme.Fonts.label`, `tracking: 3`, Farbe `Theme.Colors.textSecondary.opacity(0.6)`
   - Animation: sanftes Fade-In/Out (`.opacity` zwischen 0.4 und 1.0, `repeatForever(autoreverses: true)`, Dauer ~1.5s)
3. Falls kein expliziter Skip-Button existiert: den gesamten Screen als Tap-Target machen mit `onTapGesture { onSkip() }`

**Akzeptanzkriterium:** Im Rest Timer ist ein pulsierender "TAP TO SKIP" Text sichtbar. Tap auf den Screen (nicht nur auf einen Button) überspringt die Pause.

---

## Phase 2 – UX Core (mittlerer Aufwand, hoher Impact)

### Task 2.1 – Weight-Eingabe via Numpad (statt nur Picker)

**Problem:** Der Weight-Picker in `ExerciseDetailSheet` hat 80 Scroll-Positionen (0–200kg in 2.5kg-Schritten). Im Gym mit Handschuhen oder schwitzigen Händen ist das eine Qual.

**Dateien:** `GymBuddy/Views/Plans/PlanEditView.swift` (ExerciseDetailSheet, Zeilen ~282–346)

**Was tun:**
1. Das Weight-Setting-Card umbauen auf einen **dualen Ansatz**:
   - **Oben:** Ein `TextField` mit `keyboardType(.decimalPad)` für direkte Eingabe
     - Placeholder: `"0"`
     - Binding auf `exercise.weight` (als String bridgen, zurück zu Double parsen)
     - Styling: großer Font (`Theme.Fonts.h1`), accent-farbig, zentriert, `Theme.Colors.surface` Background
   - **Unten (kollabierbar):** Den bestehenden Wheel-Picker als optionale Hilfe behalten
     - Toggle-Button: `"USE PICKER"` / `"USE KEYBOARD"` – klein, `Theme.Colors.textSecondary`
2. Validierung: Nur positive Zahlen erlauben, max 300kg. Ungültige Eingabe → auf 0 zurücksetzen.
3. Das `@State` für den Weight-String lokal im ExerciseDetailSheet halten (kein neues Model nötig)

**Akzeptanzkriterium:** User kann Gewicht direkt eintippen. Picker bleibt als Alternative verfügbar. Kein Crash bei leerer/ungültiger Eingabe.

---

### Task 2.2 – "Zuletzt genutzt"-Datum auf Plan-Cards

**Problem:** Alle Plan-Cards sehen identisch aus. User wissen nicht welchen Plan sie zuletzt gemacht haben (relevant für PPL-Rotation).

**Dateien:**
- `GymBuddy/Models/WorkoutPlan.swift` – Model erweitern
- `GymBuddy/ViewModels/WorkoutSessionManager.swift` – beim Workout-Start Datum setzen
- `GymBuddy/Views/StartScreenView.swift` – Card-Anzeige anpassen

**Was tun:**

**Schritt A – Model:**
In `WorkoutPlan.swift` ein neues optionales Property hinzufügen:
```swift
var lastUsedAt: Date? = nil
```
SwiftData migriert das automatisch (optional Property, kein Schema-Migration-Code nötig).

**Schritt B – WorkoutSessionManager:**
In `startWorkout(plan:)` (Zeile ~33), nach dem `session = WorkoutSession(...)`, das Datum setzen:
```swift
plan.lastUsedAt = Date()
```
Kein explizites `modelContext.save()` nötig – SwiftData auto-saves.

**Schritt C – StartPlanCard:**
In der `StartPlanCard`-View (ab Zeile ~370 in `StartScreenView.swift`) unterhalb des `muscles`-Texts eine neue Zeile hinzufügen:
- Falls `plan.lastUsedAt != nil`: `"LAST USED · X DAYS AGO"` bzw. `"TODAY"` / `"YESTERDAY"`
- Falls `nil`: nichts anzeigen (kein "Never used" – zu negativem Framing)
- Styling: `font(.system(size: 10, weight: .medium))`, `tracking(1.5)`, Farbe `Theme.Colors.textSecondary.opacity(0.7)`

**Hilfsfunktion** (lokal in StartScreenView oder als Extension auf Date):
```swift
// Returns "TODAY", "YESTERDAY", "3 DAYS AGO", "2 WEEKS AGO", etc.
func relativeLabel(for date: Date) -> String
```

**Akzeptanzkriterium:** Nach dem ersten Start eines Workouts zeigt die Plan-Card danach das relative Datum. Null-State (nie benutzt) zeigt nichts extra an.

---

### Task 2.3 – WorkoutSummary: Workout-Volume anzeigen

**Problem:** Die Summary zeigt Total Time, Exercises, Sets – aber kein Gefühl für das tatsächliche Trainingsvolumen (Gewicht × Reps).

**Dateien:**
- `GymBuddy/Models/WorkoutSession.swift` – Computed Property hinzufügen
- `GymBuddy/Views/Workout/WorkoutSummaryView.swift` – Anzeige

**Was tun:**

**Schritt A – WorkoutSession:**
In `WorkoutSession.swift` ein neues Computed Property `totalVolume: Double` hinzufügen:
```swift
// Sum of (weight × reps × sets) for all exercises with weight > 0
var totalVolume: Double {
    plan.exercises
        .filter { $0.weight > 0 }
        .reduce(0) { $0 + ($1.weight * Double($1.reps) * Double($1.sets)) }
}

// Formatted: "4.800 KG" or "—" if no weight tracked
var totalVolumeFormatted: String {
    guard totalVolume > 0 else { return "—" }
    let formatted = NumberFormatter.localizedString(from: NSNumber(value: totalVolume), number: .decimal)
    return "\(formatted) KG"
}
```

**Schritt B – WorkoutSummaryView:**
In der `HStack` Stats-Row (Zeile ~63) ein viertes `statItem` hinzufügen:
```swift
statItem(value: session.totalVolumeFormatted, label: "VOLUME")
```
Die Row auf `HStack(spacing: Theme.Spacing.xl)` anpassen damit 4 Items passen. Alternativ: 2×2 Grid falls 4 in einer Reihe zu eng wird – nach Ermessen entscheiden was visuell besser aussieht.

**Akzeptanzkriterium:** WorkoutSummary zeigt das totale Volumen (oder "—" wenn kein Gewicht eingetragen war). Layout bleibt balanced.

---

## Phase 3 – Plan-Card Tap-Animation

### Task 3.1 – Visuelles Feedback beim Plan-Card Tap

**Problem:** Tap auf eine Plan-Card triggert Haptic-Feedback, aber keine visuelle Reaktion der Card selbst. In einer dunklen Gym-Umgebung ist das suboptimal.

**Dateien:** `GymBuddy/Views/StartScreenView.swift` (StartPlanCard, ab Zeile ~370)

**Was tun:**
1. Den `Button` in `StartPlanCard` durch `ButtonStyle` oder manuellen Press-State ersetzen
2. Beim Tap-Beginn (`.onLongPressGesture` oder custom `ButtonStyle`):
   - Kurzes Scale-Down: `.scaleEffect(isPressed ? 0.97 : 1.0)`
   - Linker Accent-Bar wechselt kurz von `Theme.Colors.surfaceElevated` zu `Theme.Colors.accent`
3. Animation: `.spring(response: 0.2, dampingFraction: 0.7)`

**Konkrete Implementierung:**
Den bestehenden `ScaleButtonStyle` (existiert bereits in PlanEditView) in eine separate Datei oder nach `StartScreenView` extrahieren und dort für `StartPlanCard` nutzen. Zusätzlich den 2px-Separator-Balken (Zeile ~407-409 in StartScreenView) animieren.

**Akzeptanzkriterium:** Tap auf Plan-Card zeigt kurzes Scale + Accent-Color-Flash. Fühlt sich responsiv an, ohne aufdringlich zu sein.

---

## Phase 4 – Code-Qualität

### Task 4.1 – PlanListView entfernen oder integrieren

**Problem:** `GymBuddy/Views/Plans/PlanListView.swift` existiert parallel zu `StartScreenView.swift` und zeigt redundante Plan-Listen-Funktionalität. Verwirrend für zukünftige Entwicklung.

**Dateien:**
- `GymBuddy/Views/Plans/PlanListView.swift`
- `GymBuddy.xcodeproj/project.pbxproj`

**Was tun:**
1. `PlanListView.swift` lesen
2. Prüfen ob sie irgendwo referenziert/genutzt wird (Grep nach `PlanListView`)
3. Falls nicht genutzt: Datei löschen und aus dem Xcode-Projekt entfernen (pbxproj bearbeiten oder via `xcodebuild`)
4. Falls doch genutzt: Kommentar hinterlassen warum sie noch existiert

**Akzeptanzkriterium:** Keine tote Code-Datei im Projekt. Wenn gelöscht, baut das Projekt weiterhin fehlerfrei.

---

## Commit-Strategie

Nach jeder Phase einen Commit:
```
Phase 1: git commit -m "feat: UX quick wins - cancel confirmation, exercise progress, rest timer hint"
Phase 2: git commit -m "feat: weight numpad input, last-used dates, workout volume stat"
Phase 3: git commit -m "feat: plan card tap animation"
Phase 4: git commit -m "chore: remove redundant PlanListView"
```

---

## Nicht in Scope (bewusst ausgelassen)

- Workout-History/Log (komplexes Feature, separater Task in Zukunft)
- ElevenLabs Error Handling (API-Layer, separater Task)
- Onboarding/Tutorial
- Body Metrics
- Siri Shortcuts
