import SwiftUI
import Observation
import AVFoundation

@Observable
class WorkoutSessionManager {
    var session: WorkoutSession?
    var isActive: Bool { session != nil }
    var isPaused: Bool = false

    private var timer: Timer?
    private let audio = AudioService.shared
    private let haptics = HapticService.shared
    private let nowPlaying = NowPlayingService()

    // MARK: - Initialization

    init() {
        setupRemoteCommands()
    }

    private func setupRemoteCommands() {
        nowPlaying.onPlayPause = { [weak self] in
            self?.togglePause()
        }
        nowPlaying.onSkipNext = { [weak self] in
            self?.completeSet()
        }
    }

    // MARK: - Core Actions

    func startWorkout(plan: WorkoutPlan) {
        guard !plan.exercises.isEmpty else { return }

        // Sort exercises by orderIndex
        let sortedExercises = plan.exercises.sorted { $0.orderIndex < $1.orderIndex }

        session = WorkoutSession(
            plan: plan,
            state: .active,
            currentExerciseIndex: 0,
            currentSetNumber: 1,
            restTimeRemaining: 0
        )

        isPaused = false

        // Activate Now Playing
        nowPlaying.activate()

        if let exercise = sortedExercises.first {
            audio.announceWorkoutStart(planName: plan.name, firstExercise: exercise.name)
            updateNowPlayingInfo()
        }
    }

    func completeSet() {
        guard var currentSession = session, !isPaused else { return }

        haptics.medium()

        let sortedExercises = currentSession.plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
        guard sortedExercises.indices.contains(currentSession.currentExerciseIndex) else { return }
        let currentExercise = sortedExercises[currentSession.currentExerciseIndex]

        if currentSession.currentSetNumber < currentExercise.sets {
            // Next Set Same Exercise
            currentSession.currentSetNumber += 1
            audio.announceSetCompleted()
            startRest(session: &currentSession, duration: currentExercise.restSeconds)

        } else if currentSession.currentExerciseIndex < sortedExercises.count - 1 {
            // Next Exercise
            let nextExercise = sortedExercises[currentSession.currentExerciseIndex + 1]
            currentSession.currentExerciseIndex += 1
            currentSession.currentSetNumber = 1

            audio.announceExercise(nextExercise.name)
            startRest(session: &currentSession, duration: currentExercise.restSeconds)

        } else {
            finishWorkout()
            return
        }

        self.session = currentSession
        updateNowPlayingInfo()
    }

    func skipRest() {
        endRest()
    }

    func jumpToExercise(index: Int) {
        guard var currentSession = session else { return }
        let exercises = currentSession.sortedExercises
        guard exercises.indices.contains(index) else { return }

        stopTimer()

        currentSession.currentExerciseIndex = index
        currentSession.currentSetNumber = 1
        currentSession.state = .active
        currentSession.restTimeRemaining = 0

        self.session = currentSession
        isPaused = false
        haptics.medium()

        let exercise = exercises[index]
        audio.announceExercise(exercise.name)
        updateNowPlayingInfo()
    }

    func markExerciseComplete(index: Int) {
        guard var currentSession = session else { return }
        let exercises = currentSession.sortedExercises
        guard exercises.indices.contains(index) else { return }

        stopTimer()

        if index + 1 < exercises.count {
            currentSession.currentExerciseIndex = index + 1
            currentSession.currentSetNumber = 1
            currentSession.state = .active
            currentSession.restTimeRemaining = 0
            self.session = currentSession
            haptics.success()
            let next = exercises[index + 1]
            audio.announceExercise(next.name)
            updateNowPlayingInfo()
        } else {
            // Last exercise — finish the workout
            finishWorkout()
        }
    }

    func togglePause() {
        guard session != nil else { return }

        isPaused.toggle()
        haptics.light()

        if isPaused {
            // Pause the timer
            stopTimer()
            audio.announcePaused()
        } else {
            // Resume if we were resting
            if let currentSession = session, currentSession.state == .resting {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    self?.tick()
                }
            }
            audio.announceResumed()
        }

        updateNowPlayingInfo()
    }

    func cancelWorkout() {
        stopTimer()
        nowPlaying.deactivate()
        session = nil
        isPaused = false
    }

    // MARK: - Now Playing Updates

    private func updateNowPlayingInfo() {
        guard let currentSession = session else {
            nowPlaying.clearNowPlayingInfo()
            return
        }

        let sortedExercises = currentSession.plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
        guard sortedExercises.indices.contains(currentSession.currentExerciseIndex) else { return }
        let exercise = sortedExercises[currentSession.currentExerciseIndex]

        nowPlaying.updateNowPlaying(
            exerciseName: exercise.name,
            currentSet: currentSession.currentSetNumber,
            totalSets: exercise.sets,
            isResting: currentSession.state == .resting,
            restTimeRemaining: currentSession.state == .resting ? currentSession.restTimeRemaining : nil
        )
    }

    private func updateRestTimerNowPlaying() {
        guard let currentSession = session, currentSession.state == .resting else { return }

        let sortedExercises = currentSession.plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
        guard sortedExercises.indices.contains(currentSession.currentExerciseIndex) else { return }
        let exercise = sortedExercises[currentSession.currentExerciseIndex]

        // Get next exercise name if available
        let nextExerciseName: String
        if currentSession.currentSetNumber < exercise.sets {
            nextExerciseName = exercise.name
        } else if currentSession.currentExerciseIndex < sortedExercises.count - 1 {
            nextExerciseName = sortedExercises[currentSession.currentExerciseIndex + 1].name
        } else {
            nextExerciseName = "Finish"
        }

        nowPlaying.updateRestTimer(
            exerciseName: nextExerciseName,
            currentSet: currentSession.currentSetNumber,
            totalSets: exercise.sets,
            remaining: currentSession.restTimeRemaining,
            total: exercise.restSeconds
        )
    }

    // MARK: - Internal Logic

    private func startRest(session: inout WorkoutSession, duration: Int) {
        session.state = .resting
        session.restTimeRemaining = duration
        session.originalRestDuration = duration

        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func adjustRest(by seconds: Int) {
        guard var currentSession = session,
              currentSession.state == .resting,
              !isPaused else { return }

        let newTime = currentSession.restTimeRemaining + seconds
        let maxTime = currentSession.originalRestDuration + 60
        currentSession.restTimeRemaining = max(5, min(newTime, maxTime))

        // Extend originalRestDuration if user adds time (keeps bar proportion correct)
        if currentSession.restTimeRemaining > currentSession.originalRestDuration {
            currentSession.originalRestDuration = currentSession.restTimeRemaining
        }

        self.session = currentSession
        haptics.light()
        updateRestTimerNowPlaying()
    }

    private func tick() {
        guard var currentSession = session, currentSession.state == .resting, !isPaused else { return }

        currentSession.restTimeRemaining -= 1

        // Update lockscreen
        session = currentSession
        updateRestTimerNowPlaying()

        // 10 second warning
        if currentSession.restTimeRemaining == 10 {
            haptics.warning()
        }

        // 3 second countdown - always haptic, audio respects isVoiceCountdownEnabled
        if currentSession.restTimeRemaining == 3 {
            haptics.light()
            audio.announceCountdown(3)
        } else if currentSession.restTimeRemaining == 2 {
            haptics.light()
            audio.announceCountdown(2)
        } else if currentSession.restTimeRemaining == 1 {
            haptics.medium()
            audio.announceCountdown(1)
        }

        if currentSession.restTimeRemaining <= 0 {
            endRest()
        }
    }

    private func endRest() {
        stopTimer()
        guard var currentSession = session else { return }

        currentSession.state = .active
        session = currentSession

        // Strong haptic feedback - must be noticeable even in pocket/armband
        haptics.heavy()
        audio.announceRestEnd()
        updateNowPlayingInfo()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func finishWorkout() {
        stopTimer()
        guard var currentSession = session else { return }

        currentSession.plan.lastUsedAt = Date()
        currentSession.state = .completed
        currentSession.endTime = Date()
        session = currentSession

        haptics.success()
        audio.announceWorkoutComplete()
        nowPlaying.deactivate()
    }

    /// Called from WorkoutSummaryView to dismiss and reset
    func dismissSummary() {
        session = nil
        isPaused = false
    }
}
