# GymBuddy

GymBuddy is a clean, Nike-inspired iOS training app built with SwiftUI
and SwiftData. Costs you only calories to use. No subscriptions. No noise. Just you and the gym.

---

## Features

- **Workout Plans** — pre-built PPL split plus fully custom plans, supersets included
- **Compact Editorial Home** — bold hero, your plans one tap away
- **Active Workout View** — current exercise front and center, per-set tracking (reps × weight)
- **"Letztes Mal" Values** — every set shows what you lifted last session
- **Workout History** — completed sessions are persisted; summary compares duration & volume to your last workout
- **Swipe Browsing** — swipe through exercises as a preview while your active exercise stays anchored (return pill with live rest countdown, auto-snapback when rest ends)
- **Rest Timer** — circular countdown with ±15s adjustments, haptics and local notifications
- **AI Exercise Artwork** — 40 consistent dark/orange images generated via gpt-image-1 (`scripts/generate_exercise_images.py`)
- **Background Audio** — lockscreen controls, Now Playing integration
- **Dark mode first** — because gyms don't have natural lighting

---

## Stack

- Swift / SwiftUI
- SwiftData (plans, exercises, workout history)
- Observation framework (`@Observable`)
- MediaPlayer (Now Playing / lockscreen), UserNotifications

---

## Design

V1 "Compact Editorial" — winner of a five-variant design exploration.
Black background, electric orange accent (#FF4F00), oversized bold type.
English statement headlines, German functional UI. Built to feel fast and serious.

Design docs: `DESIGN_PLAN.md`, `DESIGN_MEMORY.md`, visual reference in `docs/design/`.

---

*iOS 17+ required*
