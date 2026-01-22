# GymBuddy — iOS Architecture

> Swift + SwiftUI + SwiftData | Created: January 2025

---

## Tech Stack

| Layer | Technology | Why |
|-------|------------|-----|
| **Platform** | iOS 17+ | Latest SwiftUI features, better audio APIs |
| **Language** | Swift 5.9 | Modern concurrency, macros |
| **UI** | SwiftUI | Declarative, less code, great for simple UIs |
| **Data** | SwiftData | Apple's new persistence (simpler than Core Data) |
| **Audio** | AVFoundation + AVSpeechSynthesizer | Text-to-speech, audio ducking |
| **Haptics** | CoreHaptics | Rich haptic patterns |
| **Background** | Now Playing Info Center | Lockscreen controls |
| **Architecture** | MVVM + Observable | SwiftUI native pattern |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI Views                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ PlanListView│  │PlanEditView │  │  ActiveWorkoutView  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │ @Observable
┌────────────────────────────▼────────────────────────────────┐
│                      ViewModels                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              WorkoutSessionManager                   │    │
│  │  - currentExercise, currentSet, restTimeRemaining   │    │
│  │  - nextSet(), completeWorkout()                     │    │
│  └─────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                       Services                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ AudioService │  │ HapticService│  │ NowPlayingService│   │
│  │ - speak()    │  │ - notify()   │  │ - updateControls │   │
│  │ - duckOthers │  │ - warning()  │  │ - handleCommand  │   │
│  └──────────────┘  └──────────────┘  └──────────────────┘   │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                     SwiftData Models                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │ WorkoutPlan│──│  Exercise  │──│    Set     │             │
│  └────────────┘  └────────────┘  └────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Models

### SwiftData Models (Persisted)

```swift
@Model
class WorkoutPlan {
    var name: String                    // "Push Day"
    var exercises: [Exercise]
    var createdAt: Date
    var lastUsedAt: Date?
}

@Model
class Exercise {
    var name: String                    // "Bench Press"
    var sets: Int                       // 4
    var reps: Int                       // 8
    var weight: Double                  // 80.0
    var weightUnit: WeightUnit          // .kg or .lbs
    var restSeconds: Int                // 90
    var order: Int                      // Sort order
}

enum WeightUnit: String, Codable {
    case kg, lbs
}
```

### Runtime Models (Not Persisted)

```swift
struct WorkoutSession {
    let plan: WorkoutPlan
    var currentExerciseIndex: Int
    var currentSetNumber: Int
    var state: SessionState
    var restTimeRemaining: Int
}

enum SessionState {
    case active      // User doing a set
    case resting     // Rest timer running
    case complete    // Workout finished
}
```

---

## Key Services

### AudioService

```swift
import AVFoundation

class AudioService {
    private let synthesizer = AVSpeechSynthesizer()

    func configureSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .voicePrompt,
            options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.52  // Slightly faster than default
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }

    func announceExercise(_ exercise: Exercise, setNumber: Int) {
        let weight = Int(exercise.weight)
        let unit = exercise.weightUnit == .kg ? "kilos" : "pounds"
        speak("\(exercise.name). Set \(setNumber) of \(exercise.sets). \(exercise.reps) reps at \(weight) \(unit).")
    }

    func announceRestComplete(_ nextExercise: String) {
        speak("Let's go. \(nextExercise).")
    }

    func announceWorkoutComplete() {
        speak("Workout complete. Great work.")
    }
}
```

### NowPlayingService

```swift
import MediaPlayer

class NowPlayingService {
    func setupRemoteCommands(onToggle: @escaping () -> Void) {
        let center = MPRemoteCommandCenter.shared()

        center.togglePlayPauseCommand.isEnabled = true
        center.togglePlayPauseCommand.addTarget { _ in
            onToggle()
            return .success
        }

        // Disable unused commands
        center.playCommand.isEnabled = false
        center.pauseCommand.isEnabled = false
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
    }

    func updateNowPlaying(exercise: String, setInfo: String, restSeconds: Int) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = exercise
        info[MPMediaItemPropertyArtist] = setInfo
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        info[MPNowPlayingInfoPropertyPlaybackDuration] = Double(restSeconds)
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}
```

### HapticService

```swift
import UIKit

class HapticService {
    func setComplete() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func restWarning() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func restComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Double tap pattern
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            generator.notificationOccurred(.success)
        }
    }

    func workoutComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
```

---

## WorkoutSessionManager

```swift
import SwiftUI

@Observable
class WorkoutSessionManager {
    var session: WorkoutSession?
    var isActive: Bool { session != nil }

    private let audioService = AudioService()
    private let hapticService = HapticService()
    private let nowPlayingService = NowPlayingService()
    private var timer: Timer?

    var currentExercise: Exercise? {
        guard let session else { return nil }
        return session.plan.exercises[session.currentExerciseIndex]
    }

    func startWorkout(plan: WorkoutPlan) {
        session = WorkoutSession(
            plan: plan,
            currentExerciseIndex: 0,
            currentSetNumber: 1,
            state: .active,
            restTimeRemaining: 0
        )

        audioService.configureSession()
        nowPlayingService.setupRemoteCommands { [weak self] in
            self?.handleToggle()
        }

        if let exercise = currentExercise {
            audioService.announceExercise(exercise, setNumber: 1)
        }
    }

    func completeSet() {
        guard var session else { return }

        hapticService.setComplete()

        let exercise = session.plan.exercises[session.currentExerciseIndex]

        if session.currentSetNumber < exercise.sets {
            // More sets remaining - start rest
            session.state = .resting
            session.restTimeRemaining = exercise.restSeconds
            self.session = session
            startRestTimer()
        } else if session.currentExerciseIndex < session.plan.exercises.count - 1 {
            // Move to next exercise
            session.currentExerciseIndex += 1
            session.currentSetNumber = 1
            session.state = .resting
            session.restTimeRemaining = exercise.restSeconds
            self.session = session
            startRestTimer()
        } else {
            // Workout complete
            completeWorkout()
        }
    }

    private func startRestTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickRest()
        }
    }

    private func tickRest() {
        guard var session, session.state == .resting else { return }

        session.restTimeRemaining -= 1

        if session.restTimeRemaining == 10 {
            hapticService.restWarning()
        }

        if session.restTimeRemaining <= 0 {
            timer?.invalidate()
            session.state = .active
            self.session = session

            hapticService.restComplete()
            if let exercise = currentExercise {
                audioService.announceExercise(exercise, setNumber: session.currentSetNumber)
            }
        } else {
            self.session = session
        }
    }

    func skipRest() {
        timer?.invalidate()
        guard var session else { return }
        session.state = .active
        session.restTimeRemaining = 0
        self.session = session

        if let exercise = currentExercise {
            audioService.announceExercise(exercise, setNumber: session.currentSetNumber)
        }
    }

    private func handleToggle() {
        guard let session else { return }
        if session.state == .active {
            completeSet()
        } else {
            skipRest()
        }
    }

    private func completeWorkout() {
        timer?.invalidate()
        audioService.announceWorkoutComplete()
        hapticService.workoutComplete()
        nowPlayingService.clearNowPlaying()
        session = nil
    }
}
```

---

## Project Structure

```
GymBuddy/
├── GymBuddyApp.swift
├── ContentView.swift
├── Models/
│   ├── WorkoutPlan.swift
│   ├── Exercise.swift
│   └── WorkoutSession.swift
├── ViewModels/
│   └── WorkoutSessionManager.swift
├── Views/
│   ├── Plans/
│   │   ├── PlanListView.swift
│   │   └── PlanEditView.swift
│   ├── Workout/
│   │   ├── ActiveWorkoutView.swift
│   │   └── RestTimerView.swift
│   └── Components/
│       ├── BigButton.swift
│       └── SetIndicator.swift
├── Services/
│   ├── AudioService.swift
│   ├── HapticService.swift
│   └── NowPlayingService.swift
└── Resources/
    ├── DefaultPlans.json
    └── Assets.xcassets/
```

---

## Info.plist Configuration

```xml
<!-- Background Audio -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Create Xcode project (SwiftUI + SwiftData)
- [ ] Define data models (WorkoutPlan, Exercise)
- [ ] Build PlanListView — list all workout plans
- [ ] Build PlanEditView — create/edit a plan
- [ ] Add 3 default templates (Push, Pull, Legs)

### Phase 2: Core Workout Flow (Week 2)
- [ ] Build ActiveWorkoutView — main workout screen
- [ ] Implement WorkoutSessionManager — state machine
- [ ] Build RestTimerView — countdown display
- [ ] Add one-button "Next Set" interaction
- [ ] Implement auto-transition: set → rest → next set

### Phase 3: Audio & Haptics (Week 3)
- [ ] Implement AudioService with AVSpeechSynthesizer
- [ ] Configure AVAudioSession for ducking
- [ ] Test audio mixing with Spotify, Apple Music, Podcasts
- [ ] Implement HapticService patterns
- [ ] Add rest timer warning at 10 seconds

### Phase 4: Lockscreen & Polish (Week 4)
- [ ] Implement NowPlayingService for lockscreen controls
- [ ] Add background audio capability
- [ ] Handle app backgrounding gracefully
- [ ] Polish UI animations and transitions
- [ ] Add onboarding (first launch)

### Phase 5: Launch Prep
- [ ] App Store assets (screenshots, description)
- [ ] TestFlight beta with 5-10 gym friends
- [ ] Iterate based on feedback
- [ ] Submit to App Store

---

## Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Persistence** | SwiftData | Simpler than Core Data, Swift-native |
| **TTS** | AVSpeechSynthesizer | Dynamic content, no audio files needed |
| **Audio mixing** | `.duckOthers` | Lowers other audio during speech |
| **Backend** | None (local-only) | Simplicity, privacy, offline-first |
| **Min iOS** | 17+ | Better SwiftData, Observable macro |

---

## Getting Started

```bash
# 1. Open Xcode 15+
# 2. Create new project:
#    - iOS App
#    - SwiftUI interface
#    - SwiftData storage
#    - Bundle ID: com.yourname.gymbuddy

# 3. Set deployment target: iOS 17.0

# 4. Add capability:
#    Project → Signing & Capabilities → + Background Modes → Audio

# 5. Start building Models → Services → Views
```
