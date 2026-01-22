# GymBuddy — Design Specification

> Dark Vibe | iOS Native | Created: January 2025

---

## Design Direction

**Vibe:** "Apple Fitness meets Nike Training Club"
*   **Minimal & Premium:** energetic, confident, distraction-free.
*   **Dark Mode First:** Optimized for gym environments. Light mode supported via semantic tokens.
*   **High Contrast:** Legible at glance.
*   **Native Feel:** Uses iOS physics and patterns, but with a custom, bolder visual identity.

**Constraints:**
*   **No hardcoded styles:** All colors, spacing, and fonts must come from the `Theme` system.
*   **No third-party UI libraries:** We build our own primitives to ensure perfect control and lightweight feel.

---

## Theme System (SwiftUI)

We implement a central `Theme` struct (e.g., in `Theme.swift`) to manage all tokens.

### Colors
| Token | Dark (Default) | Light | Usage |
|-------|----------------|-------|-------|
| `bg` | `#0A0A0B` (Near Black) | `#F2F2F7` | Main screen background |
| `surface` | `#161618` | `#FFFFFF` | Cards, sheets, floating elements |
| `surfaceElevated` | `#1E1E21` | `#FFFFFF` | Modals, active states |
| `accent` | `#FF4F00` (Electric Orange) | `#FF4F00` | Primary actions, "Active" state |
| `accentDim` | `#331405` | `#FFE5D6` | Backgrounds for accent content |
| `textPrimary` | `#FAFAFA` | `#000000` | Headlines, main data |
| `textSecondary` | `#A1A1A6` | `#636366` | Labels, supporting text |
| `destructive` | `#FF453A` | `#FF3B30` | Delete, Stop |
| `success` | `#32D74B` | `#34C759` | Completed |

### Typography
*Font: SF Pro Display (System)*

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `hero` | 56px | Bold | Session timer, main set counter |
| `h1` | 34px | Semibold | Screen titles |
| `h2` | 28px | Semibold | Section headers |
| `h3` | 22px | Medium | Card titles |
| `body` | 17px | Regular | Standard text |
| `caption` | 13px | Regular | Hints, secondary labels |
| `mono` | 17px | Regular | Weights, reps (SF Mono) |

### Spacing & Layout
*   **Scale:** 4, 8, 12, 16, 24, 32, 48, 64
*   **Radius:**
    *   `small`: 8px
    *   `medium`: 12px (Cards)
    *   **`large`: 16px (Buttons)**
*   **Shadows:** Ultra-subtle, ambient only. `Color.black.opacity(0.2)` radius: 8 y: 4.

---

## Reusable Components

All screens must be built using these primitives:

### 1. `<Screen>`
*   Handles Safe Area automatically.
*   Applies standard background color (`Theme.bg`).
*   Manages correct padding (horizontal: 24px) for content.

### 2. `<PrimaryButton>`
*   **Specs:** Height 56px, Radius 16px.
*   **Style:** `Theme.accent` background, `Theme.textPrimary` (White) text.
*   **Typography:** H3 (Medium).
*   **Interaction:** Scale down to 0.98 on press. Haptic `.light` feedback.

### 3. `<SecondaryButton>`
*   **Specs:** Height 48px, Radius 12px.
*   **Style:** Transparent or `Theme.surface`, Border 1px `Theme.border`.
*   **Usage:** "Skip Rest", "Cancel".

### 4. `<Card>`
*   **Usage:** **Sparingly**. Mostly for lists (Plan List), NOT for the main Session screen.
*   **Style:** `Theme.surface`, Radius 12px.

### 5. `<SetIndicator>`
*   **Visual:** Row of dots (8px circle).
*   **States:**
    *   *Upcoming:* `Theme.surfaceElevated`
    *   *Current:* `Theme.accent` (Pulsing)
    *   *Done:* `Theme.accent` (Filled)

---

## Key Look & Feel

### 1. The Session Screen (Focus Mode)
*   **Visual Clutter: ZERO.**
*   **Hierarchy:**
    1.  Exercise Name (Top)
    2.  Set Counter "3 / 4" (Center, Hero Size)
    3.  Reps & Weight (Below, Mono)
    4.  Primary Action Button (Bottom, specific "Thumbar Action Area")
*   **Animation:**
    *   When Set Complete: subtle *flash* of green.
    *   Transition to Rest: Elements fade out, circular progress fade in.

### 2. The Rest Timer
*   **Visual:** Giant Mono Countdown.
*   **Color:** Starts White -> turns `Warning Orange` at 10s.
*   **Interaction:** "Tap anywhere to skip" (invisible button covering background).

### 3. Home Screen (Empty State)
*   *Before plans are added:*
*   **Visual:** A cool, abstract gym icon or simple illustration (monochrome).
*   **Headline:** "Start Your Journey"
*   **Subtext:** "Create your first workout plan to get started."
*   **Action:** `<PrimaryButton> Create Plan`

---

## Interactions & Motion
*   **Tab Bar:** Minimal, standard iOS but with custom symbols.
*   **Page Transitions:** Standard navigation push, but "Session" opens as a full-screen cover (modal) to maximize focus.
*   **Haptics:**
    *   Button Tap: `.light`
    *   Set Done: `.success`
    *   Timer Warning: `.warning` (pulsing)

---

## Implementation Rules
1.  **SwiftUI First:** Use `ViewModifiers` for common styles.
2.  **Theme.swift:** All colors defined in Asset Catalog but accessed via code-safe `Theme` struct.
3.  **Dark Mode:** Test on device. Ensure true black (#000000) is avoided for background to prevent smearing on OLEDs; use #0A0A0B.

