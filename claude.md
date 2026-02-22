# GymBuddy - Project Context & Rules

## Project Overview
GymBuddy is a premium, Nike-inspired fitness app built for iOS using **SwiftUI**, **SwiftData**, and the **Observation** framework.

## Architecture
- **Models:** SwiftData types (`WorkoutPlan`, `Exercise`, `ExerciseDefinition`)
- **State Management:** `@Observable` ViewModels (e.g., `WorkoutSessionManager`)
- **Persistence:** Local storage with SwiftData, User preferences in `AppSettings`
- **Audio:** `AudioService` for voice coaching (supports native & ElevenLabs)
- **UI:** Custom design system in `Theme.swift`, dark mode priority

## Coding Conventions
- Use **SwiftUI Observation** framework (`@Observable`, `@Bindable`) instead of legacy ObservableObject.
- Prefer **NavigationStack** for navigation.
- Use `Theme.Colors` and `Theme.Fonts` for all styling.
- Localized phrasing in `AudioService` (supports EN/DE).

## Key Components
- `WorkoutSessionManager`: Handles the active workout logic and timers.
- `ExerciseManager`: Manages the exercise database and seeding.
- `AppSettings`: Singleton for global user preferences.

## Bash & Shell Guidelines
- DO NOT pipe output through `head`, `tail`, `less`, or `more`.
- Use `git log --oneline -N` for git history.
- Use the provided Read tools with limit/offset.
