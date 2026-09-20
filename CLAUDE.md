# GymBuddy — Briefing für Claude Code

Diese Datei ist die Übergabe aus einer Projekt-Session vom 20.09.2026. Sie soll
verhindern, dass eine neue Session bei null anfängt. Wenn etwas hier im
Widerspruch zum Code steht, gilt der Code — dann bitte diese Datei korrigieren.

## Was die App ist

iOS-Trainings-App für das Gym. SwiftUI + SwiftData, iOS 17+, iPhone-only, komplett
offline. Version 1.0 liegt im App Store. Kein Server, keine Accounts, keine
Netzwerkzugriffe. Entwickler und Auftraggeber ist Matti (GitHub: 0xMathi).

## Die wichtigste Regel

**`main` ist der Stand, der im Store liegt, und er funktioniert.** Matti hat das
mehrfach betont: an der laufenden App darf nichts kaputtgehen. Konkret heißt das:
Änderungen klein und in sich abgeschlossen halten, nur anfassen was zur Aufgabe
gehört, und vorher sagen, welche Dateien betroffen sind.

## Zusammenarbeit mit Matti

- Er schreibt und liest Deutsch. Antworten auf Deutsch.
- Er will kleine Stellschrauben an einer fertigen App, keine großen Umbauten.
- Behauptungen über den Stand der App bitte am echten Code belegen.
  `docs/ROADMAP.md` ist ein Wunschzettel, kein Beleg — mehrere Punkte darin waren
  am 20.09. bereits überholt oder nicht mehr gewollt.
- Er testet selbst im Simulator. Was nicht gebaut wurde, wird auch nicht als
  fertig verkauft.

## Leitplanken (bewusst festgelegt, siehe docs/ROADMAP.md)

- Kein Abo, keine Pro-Version. Monetarisierung ist der freiwillige Tip Jar.
- Lean bleiben: Die App macht eine Sache — Training tracken — und die richtig gut.
- „100 % offline, die Daten verlassen nie das Handy" ist ein Markenversprechen.
- Bewusst nicht geplant: Accounts, Server, Social, KI-Trainingspläne, Apple-Watch-App,
  iPad-Layout, Übungsvideos.

## Aufbau

```
GymBuddy/
  GymBuddyApp.swift          App-Einstieg, SwiftData-Container
  Theme.swift                Farben, Fonts, Spacing (Schwarz + Orange #FF4F00)
  ViewModels/
    WorkoutSessionManager    Zentrale Zustandsmaschine des laufenden Workouts:
                             Sätze, Supersätze, Pausen-Timer, Historie schreiben
  Models/
    WorkoutPlan, Exercise    SwiftData, Plan löscht Übungen per Cascade mit
    CompletedWorkout         Persistierte Historie, Quelle der „Letztes Mal"-Werte
    AppSettings, Units       kg/lb; gespeichert wird IMMER kg, umgerechnet nur in der UI
    Strings.swift            Lokalisierung EN/DE als Runtime-Enum `L`, kein .strings
    ExerciseLocalization     Übungs- und Muskelgruppennamen EN/DE
  Views/
    StartScreenView          Startscreen mit Planliste
    Workout/ActiveWorkoutView  Das Herzstück, ~1270 Zeilen
    Workout/WorkoutSummaryView, RestTimerBar
    Plans/PlanEditView, ExercisePickerView
    OnboardingView           3 Seiten, TabView mit `page`-State
    Settings/SettingsView, TipJarView
  Services/
    ExerciseManager, HapticService
```

Ein paar Dinge, die man sonst erst suchen muss:

- Der Pausen-Timer rechnet mit echter Uhrzeit (`targetRestEndTime`), läuft also
  im Hintergrund korrekt weiter. Am Pausenende feuert eine lokale Mitteilung
  mit der Kennung `RestEnd`. Es gibt **keine** Live Activity und kein Widget-Target.
- Neue UI-Texte gehören in `Strings.swift` als `L.xyz`, nicht als Literal in die View.
- Markenzeilen auf Englisch („TIME TO WORK.", „BEAST MODE COMPLETED") bleiben in
  beiden Sprachen Englisch, das ist Absicht.

## Stand am 20.09.2026

- 1.0 ist im Store. Von Version 1.1 liegen drei Quick Wins auf `main`
  (Commit 3267f02): Workout vorzeitig beenden **und speichern**, Tap auf die
  „Letztes Mal"-Zeile übernimmt die Werte, Summary-Titel-Bug behoben.
- Keine offenen Issues. Keine Tests, keine CI.

## Am 20.09.2026 entschieden

**Ausdrücklich nicht gewollt** — bitte nicht erneut vorschlagen:

- Live Activity / Dynamic Island für den Pausen-Timer. Die Mitteilung am
  Pausenende reicht ihm völlig. (War Roadmap 1.1, Punkt 1.)
- VoiceOver- bzw. Accessibility-Pass. (War Roadmap 1.1, Punkt 6.)
- Gewichtseingabe per Tastatur und feinere Gewichtsschritte. Das Rad mit seinen
  2,5-kg-Schritten ist für ihn bewusst gut so. (War Roadmap 1.1, Punkt 5.)

**Erledigt:** Pull Request #1 wurde geschlossen, nicht gemergt. Er stammte vom
22.05. von einem anderen KI-Tool, wollte eine Historie einbauen, legte beim
Speichern aber jedes Mal einen neuen Datenspeicher an — der Verlaufs-Screen hätte
leer gelassen. Dazu kannte er weder kg/lb noch die EN/DE-Lokalisierung.

## Zweige

| Zweig | Was drauf liegt |
|---|---|
| `main` | Der Store-Stand. Basis für alles. |
| `claude/project-thread-4z8q4g` | Rückfrage vor dem Löschen eines Plans. **Ungetestet.** |
| `claude/onboarding-erklaerkarten-wuu5l2` | Drei Erklärkarten im Onboarding, dazu `docs/onboarding-erklaerkarten.md`. **Ungetestet.** |
| `app-optimierungsideen-6f6aa` | Leiche aus dem geschlossenen Pull Request #1. Ignorieren. |

Die Erklärkarten kamen daher, dass Matti beim Training auffiel, dass niemand ahnt,
dass man Übungen durchswipen kann. Eine vierte Karte zum Supersatz war gewünscht und
ist entfallen — warum, steht gleich unten.

**Beides ist ungetestet.** Geschrieben wurde es in einer Linux-Umgebung ohne Xcode,
also ohne einen einzigen Build und ohne Simulator. Erster Schritt lokal: bauen.

## Was auf dem Lösch-Zweig steht

Ein Wisch nach links über einen Plan löschte ihn bisher sofort, samt allen Übungen,
ohne Rückfrage und ohne Rückgängig. Geändert:

- Der Vollwisch löscht nicht mehr, er legt nur den Papierkorb-Knopf frei.
- Wisch-Knopf und Halte-Menü öffnen einen Bestätigungsdialog mit dem Plannamen,
  nach dem Muster des vorhandenen „Workout beenden?"-Dialogs in `ActiveWorkoutView`.
- Der Dialog hält den Namen als Kopie (`PendingPlanDeletion`), damit er beim
  Ausblenden nicht mehr auf das bereits gelöschte SwiftData-Objekt zugreift.

Zwei Dateien: `Views/StartScreenView.swift`, `Models/Strings.swift`.

Im Simulator zu prüfen: Wisch legt den Knopf frei statt zu löschen, Dialog zeigt den
richtigen Plannamen, Abbrechen behält den Plan, Löschen entfernt ihn samt Übungen,
und der Bearbeiten-Modus der Liste funktioniert weiter.

## Größter offener Fund: Supersätze sind nicht einstellbar

`Exercise.supersetId` steckt im Modell, und der `WorkoutSessionManager` fährt damit
einen vollwertigen Supersatz (Wechsel zur nächsten Übung ohne Pause, gemeinsamer
Satzzähler, Rücksprung zum Blockanfang). Die Views zeigen dafür eigene
SUPERSET-Abzeichen. Gesetzt wird das Feld aber **nirgends**: nicht im Plan-Editor,
nicht im Übungs-Sheet, und keiner der Starter-Pläne nutzt es. Nachgeprüft am
20.09. — die einzige Zuweisung ist der Initializer in `Exercise.swift`, gefüttert
aus `WorkoutPlanSeed`, wo überall `nil` steht.

Heißt: Ein Nutzer kann keinen Supersatz anlegen, die ganze Logik läuft für niemanden.
Deshalb ist die Supersatz-Erklärkarte im Onboarding entfallen — man kann nichts
erklären, was man nicht einstellen kann. Sinnvolle Reihenfolge: erst das Anlegen im
Plan-Editor nachrüsten, dann die Karte ergänzen. Das ist kein kleiner Handgriff mehr,
also vorher mit Matti klären.

## Offene Kleinigkeiten (am 20.09. im Code verifiziert, nicht bloß Roadmap)

1. „Löschen" ist zweimal fest verdrahtet statt `L.delete`: im Halte-Menü in
   `StartScreenView` und in `PlanEditView:142`. Auf Englisch steht dort Deutsch.
2. Plan duplizieren fehlt. Das Halte-Menü kennt nur Bearbeiten und Löschen.
3. `docs/ARCHITECTURE.md` ist veraltet: beschreibt `AudioService` und
   `NowPlayingService`, beide in Commit 41ef1c3 für App Review 2.5.4 entfernt.
4. Weder Tests noch CI. Die Superset-Logik in `WorkoutSessionManager` wäre der
   natürliche erste Testfall — sie ist die kniffligste Stelle im Projekt.
