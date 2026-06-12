# Design Implementation Plan: V1 „Compact Editorial"

## Summary

- **Scope:** Startscreen + Aktives Workout + Pause (Redesign) inkl. schlanker Historie
- **Gewinner:** V1 Compact Editorial (Design-Lab-Exploration vom 12.06.2026, 5 Varianten)
- **Visuelle Referenz:** `docs/design/final-v1-compact-editorial.html` (im Browser öffnen)
- **User-Tweak:** Hero mit mehr Luft nach oben (padding-top ~54pt), Pläne weiter unten — alle 3 Pläne + „+" bleiben above the fold
- **Kern-Verbesserungen:**
  1. Hero von ~70% auf ~25% Screenhöhe („TIME TO WORK."), Pläne ohne Scrollen erreichbar
  2. Reps in jeder Satz-Zeile („8 × 35 kg" statt nur Gewicht)
  3. „Letztes Mal"-Werte (Session-Persistenz, schlank — kein eigener Verlaufs-Screen)
  4. Übungsbilder zurück in die UI (Banner im Workout, Thumbnails in Cards/Listen), neu generiert via gpt-image-1
  5. Sprachsystem: englische Statement-Headlines, deutsche Funktions-UI
  6. Pause: eine Skip-Affordance statt drei; Volumen-Berechnung aus tatsächlich absolvierten Sätzen

## Files to Change

- [ ] `GymBuddy/Theme.swift` — Typo-Token ergänzen (`heroCompact` ~56pt, Ghost-Label-Style), keine neuen Farben nötig
- [ ] `GymBuddy/Views/StartScreenView.swift` — kompakter Hero, Card-Layout mit Bild-Thumbnail, Spacing per Mockup
- [ ] `GymBuddy/Views/Workout/ActiveWorkoutView.swift` — Satz-Zeilen mit Reps, Bild-Banner, Ghost-Werte, Rest-Section entrümpeln
- [ ] `GymBuddy/Views/Workout/WorkoutSummaryView.swift` — Volumen aus absolvierten Sätzen, Vergleich zur letzten Session
- [ ] `GymBuddy/Models/WorkoutSession.swift` — `totalVolume` auf absolvierte Sätze umstellen
- [ ] **NEU** `GymBuddy/Models/CompletedWorkout.swift` — SwiftData-Modelle für Historie
- [ ] `GymBuddy/ViewModels/WorkoutSessionManager.swift` — Session bei Abschluss persistieren, `lastResult(for:)`-Lookup
- [ ] `GymBuddy/Services/ExerciseImageService.swift` — Mapping auf neue gpt-image-1-Assets
- [ ] **NEU** `scripts/generate_exercise_images.py` — gpt-image-1-Generierung (~23 Übungen + 3 Plan-Motive)

## Implementation Steps (4 shippbare Phasen)

### Phase 1 — Konsistenz-Fundament
1. Sprachsystem durchziehen: Statement-Headlines englisch (`TIME TO WORK.`, `NEXT UP`), alle funktionalen Labels/Buttons deutsch (`SATZ`, `ÜBERSPRINGEN`, `ENDE`, `Satz hinzufügen`). Betroffene Strings in allen Views vereinheitlichen (heute Mix: „FERTIG/SORTIEREN" vs. „LAST USED" vs. „SÄTZE • WDH").
2. Typo-Aufräumen in `Theme.Fonts`: Mini-Labels (10–11pt mit Tracking) auf min. 11pt konsolidieren; Ghost-Label-Style (8.5–9pt nur für „LETZTES MAL"-Werte) als bewusste Ausnahme dokumentieren.

### Phase 2 — Startscreen
1. Hero ersetzen: 2 Zeilen — `TIME TO` (weiß 16% Opacity, ~42pt) / `WORK.` (Accent, ~56pt, black), padding-top ~54pt, danach ~46pt Abstand zur Sektion „DEINE PLÄNE". Einflug-Animation beibehalten.
2. `frame(minHeight: …*0.7)` und Scroll-Indikator („SELECT YOUR PLAN" + Chevron) entfernen.
3. Plan-Cards: 60×60-Bild-Thumbnail (Plan-Motiv), Name 21pt black, Muskelgruppen-Kicker (Accent), „ZULETZT · VOR X TAGEN", Chevron rechts. Edit über Kontextmenü/Swipe wie bisher.
4. List-im-ScrollView-Konstrukt (fixe `minHeight`-Berechnung) durch `VStack`/`ForEach` mit eigenem Reorder-Modus ersetzen ODER `List` als alleinigen Scroll-Container nutzen — der fragile Hack entfällt.

### Phase 3 — Aktives Workout & Pause
1. Header: Kicker `ÜBUNG 2 / 6` + 2pt-Fortschrittsbalken, Übungsname ~30pt, darunter Bild-Banner (104pt, radius 16).
2. Satz-Zeilen: `SATZ n` | `reps × weight kg` (mono; aktiv 23pt weiß, sonst 17pt grau) | Check-Kreis. Pausen-Spalte entfällt in der Zeile (Edit-Sheet behält sie). Aktive Zeile: Accent-Bar links + dunklere Fläche + Ghost-Zeile `LETZTES MAL · 32,5 KG × 8`.
3. Rest-Section: Kreis-Timer (188pt, Stroke 13) mit Restzeit mittig, darunter −15 / `PAUSE LÄUFT` / +15, ein Primär-Button `ÜBERSPRINGEN`. Entfernen: Tap-auf-Timer-Skip + „TAP TIMER TO SKIP"-Pulsing (Redundanz). „DANN · SATZ 3 VON 4 · 8 × 35 KG" als Vorschau im Header.
4. Volumen-Fix: `WorkoutSession.totalVolume` aus tatsächlich abgehakten Sätzen (`resolvedSets` bis `currentSetNumber`/Exercise-Index) berechnen, nicht aus dem Plan.

### Phase 4 — Schlanke Historie („Letztes Mal")
1. SwiftData-Modelle:
   ```swift
   @Model final class CompletedWorkout {
       var planName: String
       var startTime: Date
       var endTime: Date
       var totalVolume: Double
       @Relationship(deleteRule: .cascade) var exercises: [CompletedExercise]
   }
   @Model final class CompletedExercise {
       var name: String          // Lookup-Key (Übungsname)
       var orderIndex: Int
       var sets: [CompletedSetData] // Codable: reps, weight
   }
   ```
2. `WorkoutSessionManager`: bei `completeWorkout()` Session → `CompletedWorkout` persistieren (nur abgehakte Sätze). **Kein stiller Fallback:** Schlägt das Speichern fehl, Fehler loggen und sichtbar machen — nicht schlucken.
3. `lastResult(exerciseName:) -> (weight: Double, reps: Int)?` — jüngste `CompletedExercise` mit gleichem Namen. Anzeige als Ghost-Zeile im aktiven Satz + in „NEXT UP"-Zeilen.
4. Summary: Vergleichszeile „Letzte Session: 45:12 · 4.100 kg" unter den Stats.

### Phase 5 (parallel) — Bilder via gpt-image-1
1. Skript nach Vorgaben des `ai-image-assets`-Skills (kein `response_format`-Param, `gpt-image-1`, b64-Decode): einheitlicher Prompt-Stil — dunkler Hintergrund #0A0A0B, orange Akzent-Glow, reduzierte Gym-Silhouetten, 1024×576.
2. ~23 Übungsbilder + 3 Plan-Motive (Push/Pull/Legs) → `Assets.xcassets`, Namenskonvention `exercise_<slug>` beibehalten (bestehende Imagesets ersetzen).
3. `OPENAI_API_KEY` aus Umgebung; fehlt er → Skript bricht mit Fehler ab (keine Platzhalter-Generierung).

## Component API

- **`StartPlanCard`**: `plan`, `thumbnail: Image?`, `muscles: String`, `lastUsedLabel: String?`, `onTap`, `onEdit`
- **`SetRow`**: `index`, `reps`, `weight`, `state: .done/.active/.upcoming`, `lastResult: (Double, Int)?`, `onToggle`, `onEdit`
- **`RestView`**: `remaining`, `total`, `nextLabel`, `onAdjust(±15)`, `onSkip`
- **`WorkoutHistoryStore`** (oder im Manager): `save(session:)`, `lastResult(for exerciseName: String)`

## Required UI States

- **Start leer:** Empty-State wie bisher (Hantel-Icon + „CREATE PLAN"-CTA), Headline englisch
- **Kein „Letztes Mal"-Wert:** Ghost-Zeile ausblenden (erste Session je Übung)
- **Bild fehlt:** Thumbnail/Banner-Slot mit `surfaceElevated`-Fläche + SF-Symbol-Fallback (kein Layout-Sprung)
- **Pause < 10s:** Countdown-Farbe → `destructive` (bestehendes Verhalten erhalten)
- **Paused:** Overlay unverändert

## Accessibility Checklist

- [ ] Touch-Targets ≥ 44pt (Check-Kreise 30pt visuell → tappable Frame 44pt)
- [ ] Ghost-Labels (8.5pt) nur als Zusatzinfo — gleiche Info über Edit-Sheet erreichbar
- [ ] Dynamic Type: Übungsname mit `minimumScaleFactor`, Satz-Werte `monospacedDigit`
- [ ] VoiceOver-Labels für Check-Buttons („Satz 2 abschließen") und ±15-Buttons
- [ ] Kontrast: `textSecondary` auf `bg` bleibt ≥ 4.5:1 für funktionale Texte

## Testing Checklist

- [ ] Volumen-Berechnung: Abbruch nach Satz 3/12 → Summary zeigt nur absolvierte Sätze
- [ ] Historie: 2 Sessions desselben Plans → Ghost-Werte zeigen Session n−1
- [ ] Übung umbenennen → kein „Letztes Mal"-Wert (Name-Lookup, dokumentiertes Verhalten)
- [ ] Startscreen auf iPhone SE/15 Pro Max: 3 Pläne + „+" ohne Scrollen (SE: ggf. scrollt „+" — ok)
- [ ] Reorder/Swipe-to-delete der Pläne funktioniert nach List-Refactor weiter
- [ ] Superset-Flow unverändert (NEXT-IN-SUPERSET-Label)

## Design Tokens

- Bestehende `Theme.Colors` unverändert (Identität)
- Neu in `Theme.Fonts`: `heroLine1` (42pt black, 16% Opacity), `heroLine2` (56pt black, Accent), `ghostLabel` (8.5pt bold, tracking 0.8)
- Spacing: Hero-Top 54pt, Hero→Sektion 46pt (statt heute `xxxl`-Ketten)

---

*Generated by Design Lab (design-and-refine) — Gewinner V1 aus 5 Varianten, 12.06.2026*
