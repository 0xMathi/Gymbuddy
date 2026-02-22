# GymBuddy - Project Journal & Memory

## Project Origins
GymBuddy started as a quest to build the most "premium-feeling" workout tracker. The aesthetic is heavily inspired by Nike's digital design language.

## Historical Milestones

### Phase 1: Foundation (Jan 2024)
- Set up Theme system and base models.
- Implemented first Nike-style StartScreen.

### Phase 2: Core Engine
- Developed `WorkoutSessionManager`.
- Implemented active workout UI with rest timers.

### Phase 3: Audio & Haptics
- Added `AudioService` with randomized coaching phrasings.
- Implemented haptic signals for workout transitions.

### Phase 4: Refinement & Settings
- Integrated `ElevenLabs` for high-quality voice coaching.
- Added comprehensive Settings menu (Voice selection, Language, Verbosity).
- Optimized database seeding for 100+ exercises.

### Phase 5: PPL Integration (Ongoing)
- Transitioned to a more advanced Plan Management.
- Currently seeding the "classic" PPL (Push-Pull-Legs) routine.

## Known Architecture Decisions
- **Copy-on-Write Exercises:** When adding an exercise to a plan, we copy the data from `ExerciseDefinition` to an `Exercise` instance. This allows users to customize weight/reps for a specific plan without changing the global definition.
- **Background Seeding:** Database seeding is wrapped in background tasks to prevent main-thread UI freezes.
