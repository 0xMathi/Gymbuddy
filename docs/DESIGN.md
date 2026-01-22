# GymBuddy — Design Specification

> Dark Vibe | iOS Native | Created: January 2025

---

## Target Audience

Serious gym-goers (20-40), structured lifters who follow programs (PPL, 5x5, etc.), value efficiency over complexity, tech-savvy but want minimal phone interaction during workouts. They already use Spotify/podcasts and want their phone to "get out of the way."

---

## Design Inspiration

| Site | Why This Audience Loves It | What to Borrow |
|------|---------------------------|----------------|
| **whoop.com** | Premium fitness tech, dark aesthetic, performance-focused | High-contrast typography, subtle gradients |
| **strong.app** | Many already use it — clean, dark, no-nonsense | Workout UI patterns, familiar mental model |
| **linear.app** | Dev-favorite, ultra-minimal dark UI | Keyboard-first feel, subtle animations |
| **arc.net** | Modern iOS users love Arc's polish | Glass effects, haptic-feeling UI |

---

## Color Palette

```
Background:       #0A0A0B  (near black - easy on eyes in gym lighting)
Surface:          #161618  (cards, elevated elements)
Surface Elevated: #1E1E21  (modals, active states)
Border:           #2A2A2E  (subtle dividers)

Text Primary:     #FAFAFA  (headings, primary content)
Text Secondary:   #A1A1A6  (supporting text, labels)
Text Muted:       #636366  (placeholders, disabled)

Accent:           #32D74B  (iOS green - active/go/success)
Accent Dim:       #1B5E20  (background tint for accent)
Warning:          #FF9F0A  (rest timer ending)
Error:            #FF453A  (iOS red)
```

---

## Typography

```
Font Family: SF Pro Display (iOS system) / Inter (fallback)

Hero:        56px / 1.1  (Bold)     — Main app title
H1:          34px / 1.2  (Semibold) — Screen titles
H2:          28px / 1.25 (Semibold) — Section headers
H3:          22px / 1.3  (Medium)   — Card titles
Body:        17px / 1.5  (Regular)  — Standard text (iOS default)
Body Small:  15px / 1.4  (Regular)  — Secondary info
Caption:     13px / 1.3  (Regular)  — Labels, hints
Mono:        17px / 1.4  (SF Mono)  — Timer digits, weights, reps
```

---

## Key Screens

### 1. Workout Active Screen (The Core Experience)

```
┌─────────────────────────────────┐
│  ●●● 3:42 PM            🔊 ▶️  │  ← Status bar + audio indicator
├─────────────────────────────────┤
│                                 │
│         BENCH PRESS             │  ← Exercise name (H1, centered)
│           80 kg                 │  ← Weight (Mono, accent green)
│                                 │
│     ┌─────────────────────┐     │
│     │                     │     │
│     │        3/4          │     │  ← Current set (HUGE, 120px)
│     │                     │     │
│     │      8 reps         │     │  ← Rep target below
│     └─────────────────────┘     │
│                                 │
│   ○ ● ● ○  ← set indicators     │  ← Dots: done/current/upcoming
│                                 │
│  ┌─────────────────────────┐    │
│  │                         │    │
│  │     [ DONE / NEXT ]     │    │  ← Giant tap target (full width)
│  │                         │    │
│  └─────────────────────────┘    │
│                                 │
│  Next: Incline Dumbbell 24kg    │  ← Subtle preview
└─────────────────────────────────┘
```

### 2. Rest Timer Screen (Auto-appears after set)

```
┌─────────────────────────────────┐
│           REST                  │  ← Label (caption, muted)
│                                 │
│          1:47                   │  ← Countdown (120px, mono)
│         ━━━━━━━○━━━             │  ← Progress ring or bar
│                                 │
│    Tap anywhere to skip         │  ← Hint (muted)
│                                 │
│  ┌─────────────────────────┐    │
│  │      [ SKIP REST ]      │    │  ← Secondary action
│  └─────────────────────────┘    │
└─────────────────────────────────┘
```

**Timer States:**
- At 10 seconds: bar turns **warning orange**
- At 0: **haptic pulse** + audio "Let's go, bench press"

### 3. Workout Plan List (Home)

```
┌─────────────────────────────────┐
│  GymBuddy              [+]      │
├─────────────────────────────────┤
│                                 │
│  TODAY                          │
│  ┌─────────────────────────┐    │
│  │ 💪 Push Day         →   │    │
│  │ 6 exercises · ~55 min   │    │
│  └─────────────────────────┘    │
│                                 │
│  YOUR PLANS                     │
│  ┌─────────────────────────┐    │
│  │ Pull Day                │    │
│  │ Leg Day                 │    │
│  │ Upper/Lower A           │    │
│  └─────────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

---

## Component Specs

| Component | Specs | States |
|-----------|-------|--------|
| **Primary Button** | Height: 56px, radius: 14px, full-width, bg: accent green | default, pressed (scale 0.98), disabled (30% opacity) |
| **Secondary Button** | Height: 48px, radius: 12px, border: 1px #2A2A2E | default, pressed, disabled |
| **Exercise Card** | Padding: 16px, radius: 12px, bg: surface | default, active (accent border) |
| **Set Indicator Dot** | 8px circle | upcoming (#2A2A2E), current (accent), done (accent, filled) |
| **Timer Display** | SF Mono, 120px, tabular nums | running (white), warning (<10s: orange), done (green flash) |

---

## Audio/Haptic Design

| Event | Audio | Haptic |
|-------|-------|--------|
| Set complete tap | Soft "tick" | Light impact |
| Rest timer start | None (silent) | None |
| Rest 10s warning | Subtle tone rise | Warning haptic |
| Rest complete | "Next up: [exercise]" | Strong double-tap |
| Workout complete | "Workout complete. Great work." | Success pattern |

---

## Design Principles

1. **Glanceable** — Info readable from arm's length, sweaty fingers
2. **One-hand, one-thumb** — All primary actions in thumb zone
3. **Silent by default** — Only speaks when adding value
4. **Dark-first** — Gym lighting varies; dark mode is easier
5. **No clutter** — If it doesn't help the current set, hide it

---

## iOS Native Elements

- SF Pro Display / SF Mono fonts (system)
- SF Symbols for icons
- UINotificationFeedbackGenerator for haptics
- Standard iOS safe areas and margins
- Lockscreen Now Playing integration
