# GymBuddy — Product Requirements Document

> Napkin-level PRD | Created: January 2025

---

## Problem

Gym-goers constantly check their phones between sets to see what's next, how many reps, what weight, and when rest is over. This breaks focus, drains mental energy, and makes workouts feel fragmented. Existing apps are bloated with features (nutrition, social, analytics) that add friction instead of reducing it.

---

## Solution

GymBuddy is an audio-first iOS app that guides you through your workout via short voice announcements—while your music/podcast keeps playing. It tells you what's next, stays silent during sets, and nudges you when rest is over. One giant button. Zero screen-staring.

---

## Target Users

- **Primary:** Intermediate lifters (1+ years) following structured programs (PPL, Upper/Lower, 5x5)
- **Age:** 22-38, predominantly male initially
- **Behavior:** Already uses Spotify/podcasts during workouts, owns AirPods
- **Pain:** Hates app-switching and screen unlocking between sets
- **Values:** Efficiency, focus, simplicity over features

---

## Key Features (Priority Order)

| # | Feature | Why It Matters |
|---|---------|----------------|
| 1 | **Audio announcements** — exercise, sets, reps, weight | Core value prop. Hands-free guidance. |
| 2 | **Auto rest timer** with haptic + audio cue at end | No manual tracking, stay in flow |
| 3 | **One-button control** + lockscreen integration | Minimal interaction required |
| 4 | **Workout plan builder** — create & repeat templates | Set it once, use forever |
| 5 | **Background audio mixing** — overlay on Spotify etc. | Doesn't replace their music |

---

## Out of Scope (Intentionally)

- Nutrition tracking
- Form correction / video
- Social features / leaderboards
- Progress charts / analytics
- AI coaching / recommendations
- Android (MVP is iOS-only)

---

## Success Metrics

| Metric | Target | Why |
|--------|--------|-----|
| **Workout completion rate** | >80% of started workouts finished | Core engagement signal |
| **D7 retention** | >40% | Users coming back after first week |
| **Audio enabled rate** | >90% | Validates core differentiator is used |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| iOS audio mixing is finicky (ducking, interruptions) | Extensive testing with Spotify, Apple Music, podcast apps |
| Users expect more features (stats, progress) | Strong positioning: "GymBuddy does ONE thing perfectly" |
| Subscription fatigue — another $5/month app | Generous free tier (2 workouts/week), clear value |

---

## MVP Scope (v1.0)

1. Create workout plan (exercises, sets, reps, weight, rest time)
2. Run workout with audio announcements + rest timer
3. Lockscreen controls (play/pause = next set)
4. 3 pre-built templates (Push, Pull, Legs)

---

## Next Steps

1. **Prototype audio mixing** — Validate iOS AVAudioSession ducking works reliably with Spotify
2. **Build workout flow** — Core active workout screen + rest timer
3. **Dogfood it** — Use it for 2 weeks of personal training before any user testing

---

## PMF Score Summary

| Dimension | Score |
|-----------|-------|
| Problem Clarity | 8/10 |
| Market Size | 7/10 |
| Uniqueness | 7/10 |
| Feasibility | 9/10 |
| Monetization | 7/10 |
| Timing | 7/10 |
| Virality | 6/10 |
| Defensibility | 5/10 |
| Team Fit | 9/10 |
| Ralph Factor | 8/10 |
| **Average** | **7.3/10** |
