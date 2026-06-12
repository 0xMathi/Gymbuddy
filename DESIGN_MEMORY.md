# Design Memory — GymBuddy

## Brand Tone
- **Adjektive:** bold, fast, serious, premium, brutalist-typography („Nike trifft Apple Fitness")
- **Sprachsystem:** Englische Statement-Headlines (`TIME TO WORK.`, `NEXT UP`) + deutsche Funktions-UI (`SATZ`, `ÜBERSPRINGEN`, `Satz hinzufügen`). Kein wilder Mix.
- **Vermeiden:** Verspieltes, Emojis als Icons, Light-Mode-Denken, mehr als eine Affordance pro Aktion

## Layout & Spacing
- **Dichte:** komfortabel; Workout-Screen darf dichter sein als Start
- **Hero:** kompakt (~25% Screenhöhe), viel Luft oben (~54pt), Inhalte above the fold — der Auftritt darf nie die tägliche Aktion verdrängen
- **Radius:** Cards 16, große Container 20–24, Buttons als Pill (height/2)
- **Kein** List-im-ScrollView mit manueller Höhenberechnung

## Typography
- SF Pro (System), Black/Bold für Headlines, `monospacedDigit`/SF Mono für alle Zahlen (Gewicht, Reps, Timer)
- Headlines: 42–56pt (Hero), 30pt (Übungsname), 21pt (Card-Titel)
- Funktions-Labels ≥ 11pt; einzige Ausnahme: „Ghost"-Vorwerte 8.5pt (Zusatzinfo, nie einziger Zugang)
- Uppercase + Tracking (1.5–3) für Kicker/Labels

## Color
- `bg #0A0A0B` (nie reines Schwarz, OLED), `surface #161618`, `surfaceElevated #1E1E21`
- **Accent `#FF4F00` (Electric Orange)** — Primäraktionen, aktiver Zustand, Fortschritt. Sparsam, dann kräftig.
- `success #32D74B` nur für erledigt, `destructive #FF453A` nur für Ende/Löschen/Timer-Warnung
- Dark-only first

## Interaction Patterns
- **Satz abhaken:** Check-Kreis in der Zeile (kein globaler „Complete"-Button)
- **„Letztes Mal"-Werte:** Ghost-Zeile unter dem aktiven Satz — Progression sichtbar machen, wo sie gebraucht wird
- **Pause:** Kreis-Timer + ±15 + genau EIN Skip-Button; Vorschau „DANN · …" im Header
- **Edit:** Wheel-Picker-Sheet (Reps/Gewicht/Pause) bleibt das Muster
- **Haptik:** light = Tap, medium = Auswahl/Delete, heavy = Satz fertig / Workout-Start

## Bilder
- Übungs-/Plan-Bilder via gpt-image-1, einheitlicher Stil: dunkler BG, orange Glow, reduzierte Silhouetten, 1024×576
- Einsatz: Banner im aktiven Workout (104pt), Thumbnails 60pt (Plan-Cards) / 38pt (Listen)
- Immer Fallback (surfaceElevated + SF-Symbol) ohne Layout-Sprung

## Accessibility Rules
- Touch-Targets ≥ 44pt (visuell kleinere Elemente bekommen größere tappable Frames)
- Zahlen immer `monospacedDigit` (kein Zittern beim Countdown)
- VoiceOver-Labels für Icon-only-Buttons

## Repo Conventions
- Alle Tokens über `Theme.swift` (Colors/Fonts/Spacing/Layout) — keine hardcodierten Styles
- Keine Third-Party-UI-Libraries; eigene Primitives (`PrimaryButton`, `SecondaryButton`)
- SwiftData + `@Observable`; Fehler beim Persistieren niemals still schlucken

## Entschiedene Design-Fragen (Lab 12.06.2026)
- V1 „Compact Editorial" gewann gegen Full-Bleed (V2), Data-Cockpit (V3), Focus-Mode (V4), Card-Stack (V5)
- Abgelehnt damit: Orange-Takeover-Pause, Satz-Tabelle mit Spalten, Riesen-Satzzähler, Swipe-Deck
- Historie bewusst schlank: nur „Letztes Mal"-Werte, kein Verlaufs-Screen (vorerst)

---

*Updated by Design Lab (design-and-refine), 12.06.2026*
