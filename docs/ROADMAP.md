# GymBuddy Roadmap — nach dem 1.0-Launch (Stand: 06.07.2026)

**Leitplanken (bewusst festgelegt):**
- Kein Abo, keine Pro-Version. Monetarisierung = Tip Jar, fertig.
- Lean bleiben: Die App macht EINE Sache — Training tracken — und die richtig gut.
- Jedes Update braucht einen klaren Nutzen für Bestandsnutzer + einen guten What's-New-Text.
- „100 % offline, deine Daten verlassen nie dein Handy" ist ein Markenversprechen.
  Kein Feature darf es aufweichen (Apple Health & iCloud: siehe unten, beide bleiben on-device/opt-in).

---

## Version 1.1 — „Der Timer wird erwachsen" (Fokus-Release)

Ein Thema, klar erzählbar: **Der Pausen-Timer lebt jetzt auf dem Lockscreen.**
Plus die UX-Lücken, die beim echten Benutzen auffallen.

### 1. Live Activity + Dynamic Island für den Pausen-Timer ⭐ Headline-Feature
Ersetzt sauber (und Apple-konform) das entfernte Now-Playing-Widget aus der Rejection.

**Verhalten:**
- Pause startet → Live Activity erscheint: Countdown, Fortschrittsbalken, nächste Übung
  („PAUSE · 1:45 · Dann: Schrägbankdrücken")
- Dynamic Island: kompakt = Countdown-Ring; expanded = Countdown + „Überspringen"-Button
- Pause endet/übersprungen/Workout beendet → Activity verschwindet

**Technik (durchdacht):**
- Neues Target `GymBuddyWidgets` (WidgetKit + ActivityKit), `NSSupportsLiveActivities` in Info.plist
- `ActivityAttributes`: exerciseName, nextExercise, `endDate`
- Countdown ohne Push/Polling: `Text(timerInterval:)` + `ProgressView(timerInterval:)` —
  das System zählt selbst, wir senden nur Start/Update/Ende. Passt perfekt, weil der Timer
  schon Wall-Clock-basiert ist (`targetRestEndTime`).
- „Überspringen"-Button als `LiveActivityIntent` — läuft im App-Prozess, kann direkt
  `WorkoutSessionManager.skipRest()` aufrufen. ±15s-Buttons bewusst NICHT (Island bleibt ruhig).
- Update bei ±15s in der App: neue endDate pushen. Ende bei endRest/skip/finish/cancel.
- Aufwand: ~2–3 Sessions. Risiko klein, alles lokale APIs (iOS 16.2+, wir sind iOS 17+).

**Bonus fast gratis:** Das Widget-Target ermöglicht später Home-Screen-Widgets (1.2).

### 2. „Beenden & speichern" — die größte UX-Lücke 🔴
Heute gilt: ENDE-Button = alles verwerfen („Dein Fortschritt geht verloren"). Wer nach 4 von
6 Übungen legitim aufhört, verliert sein Log — außer er kennt den Umweg über „Als erledigt
markieren" bei der letzten Übung. Das weiß niemand.

**Fix:** Der ENDE-Dialog bekommt zwei Optionen:
- **„Beenden & speichern"** → ruft `finishWorkout()` (persistiert eh nur erledigte Sätze ✓)
- „Verwerfen" (destruktiv, rot) → wie bisher
Aufwand: winzig. Wirkung: groß — verlorene Workouts sind der schnellste Weg zu 1-Sterne-Reviews.

### 3. Summary-Titel-Bug fixen 🐛
`WorkoutSummaryView` zeigt als Titel `plan.name.components(separatedBy: " ").last` —
bei „Push Day" steht da nur **„DAY"** (heute im Simulator gesehen). Fix: kompletten
Plan-Namen anzeigen. Einzeiler.

### 4. Ghost-Werte antippen = übernehmen ⭐ Klein, aber Liebling
Die „LETZTES MAL · 80 KG × 8"-Zeile ist heute nur Anzeige. **Tap auf die Ghost-Zeile
übernimmt Gewicht + Wiederholungen in den aktuellen Satz.** Ein Tap statt sechs
Picker-Interaktionen — genau der Flow „gleiches Gewicht wie letztes Mal", der 80 % der
Sätze abdeckt. (Dezente Haptik + kurzes Aufleuchten der Werte als Feedback.)

### 5. Gewichtseingabe: Feinschliff am Edit-Sheet
- **Tastatur-Alternative:** kleines ⌨️-Symbol im Sheet → Zahlenfeld für direkte Eingabe
  (32,5 kg tippen statt kurbeln). Wheel bleibt Standard.
- **Feinere Schritte:** 1,25-kg-Schritte (kg) bzw. 2,5-lb-Schritte (lb) — Mikro-Progression
  ist Realität am Kabelzug. Alternativ: Wheel behält 2,5er, Tastatur erlaubt alles.

### 6. Accessibility-Pass (klein, aber Apple-relevant)
- VoiceOver-Labels für Satz-Checkboxen („Satz 2, 8 Wiederholungen, abhaken"), Timer, Plan-Cards
- Dynamic-Type-Check auf den 4 Kernscreens (Start, Workout, Timer, Summary)
- `reduceMotion` respektieren (Konfetti aus)
Apple featured gern zugängliche Apps — und es ist schlicht richtig. Aufwand: 1 Session.

### 7. App-Icon nachschärfen (aus dem ASO-Audit)
Das vertikale „G-Y-M" wird bei 60 px (Suchergebnisse) klein. Variante bauen: größere,
fettere Buchstaben oder nur „G" mit Orange-Akzent. A/B-Vergleich als Mockup, dann entscheiden.

### 8. Mitfahrende Kleinigkeiten
- Beschreibungs-Update DE (liegt fertig in `app-store-listing.md`: „nur trainieren wollen",
  „Gebaut für dich und das Gym.")
- Neuer Store-Screenshot Slot 4: Timer **mit Dynamic Island** zeigen (Feature verkauft sich selbst)
- What's New (Entwurf): „Der Pausen-Timer lebt jetzt auf deinem Lockscreen und in der Dynamic
  Island — mit Überspringen-Button. Außerdem: Workouts vorzeitig beenden & speichern,
  ‚Letztes Mal'-Werte mit einem Tap übernehmen, feinere Gewichtsschritte."

---

## Version 1.2 — „Verlauf" (das frühere ‚Pro'-Feature, jetzt für alle)

Da keine Pro-Version kommt: **Der Verlauf wird das kostenlose Herzstück-Update.**
Die Daten existieren seit 1.0 (`CompletedWorkout` wird längst gespeichert) — Bestandsnutzer
öffnen das Update und sehen sofort *ihren* Verlauf. Das ist der beste What's-New-Moment,
den eine App haben kann.

**Scope (bewusst schlank):**
1. **Verlauf-Screen** (Einstieg über Startscreen, z. B. Kalender-Symbol neben Settings):
   Liste nach Monat gruppiert — Datum, Plan-Name, Dauer, Volumen, Satz-Anzahl
2. **Workout-Detail:** Übungen mit allen Sätzen (read-only, gleiche Optik wie Live-Workout)
3. **PR-Erkennung:** pro Übung „schwerster Satz aller Zeiten" — PR-Badge im Detail +
   dezentes „Neuer Rekord 🏆" auf der Summary, wenn im Workout ein PR fiel
4. **Zwei Charts, nicht zwanzig** (Swift Charts, nativ):
   - Volumen pro Woche (Balken, letzte 12 Wochen)
   - Pro Übung: schwerstes Gewicht über Zeit (Linie)
5. **Streak-Zeile** auf dem Startscreen: „3 Workouts diese Woche" (kein Guilt-Tripping,
   keine Feuer-Emojis — GymBuddy nörgelt nicht)
6. **Home-Screen-Widget** (nutzt das 1.1-Widget-Target): letztes Workout + Wochen-Streak

**Nicht im Scope (bewusst):** Kalorien, Körpergewicht, Fotos, Social. Andere Apps.

---

## Version 1.3 — „Öffnung" (Kandidaten, Reihenfolge nach Lust & Feedback)

1. **Apple-Health-Export (opt-in):** Abgeschlossene Workouts als Krafttraining-Workout
   in Health schreiben (write-only, keine Lese-Rechte). Bleibt on-device → „Data Not
   Collected" bleibt wahr. Settings-Toggle, Standard: aus.
2. **Plan-Export/-Teilen:** Plan als Datei/QR-Code exportieren & importieren — offline-
   freundliches „Schick mir deinen Push Day". Kein Server, kein Account, passt zur Marke.
3. **Plate Calculator:** Tap aufs Gewicht im aktiven Satz → „pro Seite: 20 + 5 + 1,25"
   (Hantelstangen-Gewicht in Settings, 20 kg Standard). Winzig, Lifter lieben es.
4. **Dritte Sprache als Test (Spanisch):** Runtime-`L`-Enum macht es mechanisch einfach;
   ES ist der größte ungenutzte Store-Markt. Erst machen, wenn EN/DE-Downloads es rechtfertigen.
5. **iCloud-Backup (opt-in, gut erklärt):** SwiftData + CloudKit private DB. Heikel wegen
   „verlässt nie dein Handy" → Formulierung: „Optional: verschlüsseltes Backup in DEINER
   iCloud". Nur angehen, wenn Nutzer nach Gerätewechsel-Support fragen (kommt garantiert).

## Bewusst NICHT auf der Roadmap
- ❌ Pro/Abo/Paywall (Entscheidung)
- ❌ Accounts, Server, Social-Features, KI-Trainingspläne
- ❌ Apple-Watch-App (riesiger Aufwand, eigenes Produkt — nur bei massiver Nachfrage)
- ❌ iPad (bräuchte eigenes Layout + neue Screenshots; iPhone-only bleibt)
- ❌ Übungs-Videos/Anleitungen (macht die App zum Lexikon statt zum Log)

---

## Vereinbarte Strategie (06.07.2026)

**Bauen in einem Fluss, releasen in zwei Schnitten:** durchgehend auf `main` entwickeln;
sobald der Timer-Block fertig ist, geht 1.1 raus, während der Verlauf nahtlos weiterwächst.
Zwei Updates = zwei Geschichten (Matti: „mehr zu erzählen statt alles abzufrühstücken").

## Empfohlene Reihenfolge & Rhythmus

| Release | Thema | Kern | Bauch-Aufwand |
|---|---|---|---|
| **1.1** | Timer & Feinschliff | Live Activity, Beenden&Speichern, Ghost-Tap, Bug | ~4–6 Sessions |
| **1.2** | Verlauf | History + PRs + 2 Charts + Widget | ~5–8 Sessions |
| **1.3** | Öffnung | Health-Export, Plan-Teilen, Plate Calculator | à la carte |

Faustregel: lieber alle 4–6 Wochen ein kleines, rundes Update (hält das „zuletzt
aktualisiert"-Signal im Store frisch — Rankingfaktor!) als ein Riesen-Update im Winter.
Nach jedem Release: Reviews lesen & beantworten — Feature-Wünsche der echten Nutzer
schlagen jede Roadmap.
