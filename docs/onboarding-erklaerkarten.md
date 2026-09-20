# Onboarding-Erklärkarten — Stand & Übergabe

Branch: `claude/onboarding-erklaerkarten-wuu5l2`, am 20.09.2026 nach `main` gemergt.

## Was drauf liegt

Drei Erklärkarten im Onboarding, direkt nach dem kg/lb-Schritt. Das Onboarding
hat damit 6 Seiten statt 3, die Punkte unten zählen automatisch mit.
Jede Karte hat oben rechts "Überspringen" — das springt direkt auf die letzte
Seite (Mitteilungen). Gezeigt wird das Ganze weiterhin nur beim allerersten
Start, daran wurde nichts geändert.

Geänderte Dateien:
- `GymBuddy/Views/OnboardingView.swift` — die drei Seiten plus die Mini-Mockups
- `GymBuddy/Models/Strings.swift` — die neuen Texte, EN und DE

Die Mockups sind komplett aus `Theme.swift` und SF Symbols gebaut. Keine neuen
Bilddateien, keine neuen Abhängigkeiten. Die Satz-Zeile im Mockup zeigt das
Gewicht in der Einheit, die eine Seite vorher gewählt wurde.

### Die Karten

1. **Wisch dich durch.** — "Wisch im Training nach links oder rechts und sieh dir
   jede Übung an. Dein laufender Satz bleibt, wo er ist — erst „Hier
   weitermachen" springt wirklich hin."
   Bild: die aktive Übungskarte, dahinter lugt die nächste hervor, darunter
   Pfeile nach links und rechts.

2. **Letztes Mal, ein Tipp.** — "Unter dem aktiven Satz steht, was du letztes Mal
   gestemmt hast. Tipp drauf, und Gewicht und Wiederholungen stehen drin."
   Bild: die aktive Satz-Zeile mit dem "LETZTES MAL"-Label in Orange.

3. **Jeder Satz, deiner.** — "Tipp einen Satz an und ändere Gewicht,
   Wiederholungen und Pause nur für diesen Satz. Nach links wischen löscht ihn."
   Bild: dieselbe Zeile halb nach links gewischt, dahinter der rote Papierkorb.

## Was offen ist

**Die Supersatz-Karte fehlt.** Der ursprüngliche Grund dafür ist entfallen:
`supersetId` wird seit 1.1.1 im Plan-Editor gesetzt (`PlanEditView`, Toggle im
Übungs-Detail; `WorkoutPlan.normalizeSupersets()` hält die Gruppen bei Reorder
und Delete konsistent). Eine vierte Karte hätte also jetzt etwas zu erklären –
sie ist bewusst noch nicht gebaut, nicht mehr blockiert.

## Im Simulator prüfen

Onboarding erscheint nur beim ersten Start. Zum erneuten Anschauen entweder die
App im Simulator löschen und neu installieren, oder in den Einstellungen der
App den Schlüssel `hasCompletedOnboarding` zurücksetzen.

Worauf zu achten ist:
- Die Karten sollten sich mit dem Finger durchwischen lassen, so wie die ersten
  beiden Seiten auch.
- "Überspringen" landet auf der Mitteilungen-Seite.
- Auf einem kleinen Gerät (iPhone SE) kontrollieren, ob Text und Mockup noch
  zwischen die Ränder passen.
- Einmal auf Englisch gegenlesen (Gerätesprache umstellen).

**Build-Stand:** Durchgeklickt im Simulator, 20.09.2026.

- iPhone 17 Pro, Deutsch: alle drei Karten, Wischen zwischen den Karten,
  „Überspringen" landet auf der Mitteilungen-Seite.
- iPhone SE (3. Gen.), Englisch, lb: Text und Mockups passen zwischen die Ränder.

Drei Fehler kamen dabei raus und sind gefixt: der rote Lösch-Hintergrund der
dritten Karte lief über die halbe Seite (ein `RoundedRectangle` als
ZStack-Geschwister hat keine eigene Höhe – die Satz-Zeile gibt sie jetzt vor);
und auf dem SE brachen in lb beide Mockup-Zeilen ab, statt zu schrumpfen.

Zum Ansehen einzelner Seiten ohne Neuinstallation: `page` temporär aus den
UserDefaults lesen und mit `simctl launch … -VerifyStartPage 3` starten.
Sprache/Einheit lassen sich mit `-AppleLanguages "(en)" -AppleLocale en_US`
mitgeben.
