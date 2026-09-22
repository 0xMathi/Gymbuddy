import SwiftUI
import SwiftData
import Observation
import UserNotifications

@Observable
class WorkoutSessionManager {
    /// The app's single instance — SkipRestIntent (Live Activity button) needs
    /// process-wide access. Previews may still create their own instances.
    static let shared = WorkoutSessionManager()

    /// Every change is mirrored to UserDefaults, so a workout survives iOS
    /// killing the app in the background (restored in `configure`).
    var session: WorkoutSession? {
        didSet { persistSnapshot() }
    }
    var isActive: Bool { session != nil }

    /// The set checked off last (exercise index, 1-based set number) — the only
    /// one that can be taken back by tapping its checkbox again.
    private(set) var undoableSet: (exerciseIndex: Int, setNumber: Int)?

    /// Per exercise name: the set results from the most recent completed workout
    private(set) var lastResults: [String: [CompletedSetData]] = [:]
    /// Duration + volume of the previous session of the same plan (for the summary comparison)
    private(set) var previousSessionStats: (duration: TimeInterval, volume: Double)?

    private var timer: Timer?
    private let haptics = HapticService.shared
    private var modelContext: ModelContext?

    private var targetRestEndTime: Date?

    /// What survives the app being killed mid-workout. Rest is stored as a
    /// wall-clock end, so a restored timer continues exactly where it would be.
    private struct SessionSnapshot: Codable, Equatable {
        let planID: UUID
        let startTime: Date
        let exerciseIndex: Int
        let setNumber: Int
        let restEndTime: Date?
        let restDuration: Int
    }
    private static let snapshotKey = "activeWorkoutSnapshot"
    /// tick() republishes the session every second — only write real changes
    private var lastSavedSnapshot: SessionSnapshot?

    // MARK: - Initialization

    /// Must be called once at app start — history features refuse to work silently without it.
    /// Also brings back a workout that was running when the app was killed.
    func configure(with context: ModelContext) {
        modelContext = context
        restoreSession()
    }

    // MARK: - Core Actions

    func startWorkout(plan: WorkoutPlan) {
        guard !plan.exercises.isEmpty else { return }

        session = WorkoutSession(
            plan: plan,
            state: .active,
            currentExerciseIndex: 0,
            currentSetNumber: 1,
            restTimeRemaining: 0
        )

        plan.lastUsedAt = Date()
        undoableSet = nil

        loadHistory(for: plan)
    }

    func completeSet() {
        guard var currentSession = session else { return }

        haptics.medium()
        undoableSet = (currentSession.currentExerciseIndex, currentSession.currentSetNumber)

        // Ticking the next set while resting means the rest is over
        if currentSession.state == .resting {
            clearRestTimer()
            currentSession.state = .active
        }

        let sortedExercises = currentSession.plan.exercises.sorted { $0.orderIndex < $1.orderIndex }
        guard sortedExercises.indices.contains(currentSession.currentExerciseIndex) else { return }
        let currentExercise = sortedExercises[currentSession.currentExerciseIndex]

        // 1. Check Superset Status
        let hasNextInSuperset: Bool = {
            if let ssid = currentExercise.supersetId,
               currentSession.currentExerciseIndex + 1 < sortedExercises.count {
                return sortedExercises[currentSession.currentExerciseIndex + 1].supersetId == ssid
            }
            return false
        }()
        
        let hasPrevInSuperset: Bool = {
            if let ssid = currentExercise.supersetId,
               currentSession.currentExerciseIndex > 0 {
                return sortedExercises[currentSession.currentExerciseIndex - 1].supersetId == ssid
            }
            return false
        }()

        if hasNextInSuperset {
            // Jump to next exercise in superset, SAME set number, NO REST
            currentSession.currentExerciseIndex += 1
            self.session = currentSession
            return
            
        } else if hasPrevInSuperset {
            // We just finished the last exercise in the superset
            if currentSession.currentSetNumber < currentExercise.sets {
                // Next Set for the entire Superset: go back to the first exercise
                currentSession.currentSetNumber += 1
                
                var firstIndex = currentSession.currentExerciseIndex
                while firstIndex > 0 && sortedExercises[firstIndex - 1].supersetId == currentExercise.supersetId {
                    firstIndex -= 1
                }
                currentSession.currentExerciseIndex = firstIndex
                
                startRest(session: &currentSession, duration: currentExercise.restSeconds)
            } else {
                // Superset completely done. Move to next block.
                if currentSession.currentExerciseIndex < sortedExercises.count - 1 {
                    currentSession.currentExerciseIndex += 1
                    currentSession.currentSetNumber = 1
                    startRest(session: &currentSession, duration: currentExercise.restSeconds)
                } else {
                    finishWorkout()
                    return
                }
            }
            
        } else {
            // Normal (Non-Superset) logic
            if currentSession.currentSetNumber < currentExercise.sets {
                currentSession.currentSetNumber += 1
                startRest(session: &currentSession, duration: currentExercise.restSeconds)
            } else if currentSession.currentExerciseIndex < sortedExercises.count - 1 {
                currentSession.currentExerciseIndex += 1
                currentSession.currentSetNumber = 1
                startRest(session: &currentSession, duration: currentExercise.restSeconds)
            } else {
                finishWorkout()
                return
            }
        }

        self.session = currentSession
    }

    func skipRest() {
        endRest()
    }

    /// Takes back the set checked off last: it becomes the active set again
    /// and the rest it started is dropped.
    func undoLastSet() {
        guard var currentSession = session, let ticked = undoableSet else { return }

        clearRestTimer()
        currentSession.currentExerciseIndex = ticked.exerciseIndex
        currentSession.currentSetNumber = ticked.setNumber
        currentSession.state = .active
        currentSession.restTimeRemaining = 0

        undoableSet = nil
        session = currentSession
        haptics.light()
    }

    func jumpToExercise(index: Int) {
        guard var currentSession = session else { return }
        let exercises = currentSession.sortedExercises
        guard exercises.indices.contains(index) else { return }

        clearRestTimer()
        undoableSet = nil

        currentSession.currentExerciseIndex = index
        currentSession.currentSetNumber = 1
        currentSession.state = .active
        currentSession.restTimeRemaining = 0

        self.session = currentSession
        haptics.medium()
    }

    func markExerciseComplete(index: Int) {
        guard var currentSession = session else { return }
        let exercises = currentSession.sortedExercises
        guard exercises.indices.contains(index) else { return }

        clearRestTimer()
        undoableSet = nil

        if index + 1 < exercises.count {
            currentSession.currentExerciseIndex = index + 1
            currentSession.currentSetNumber = 1
            currentSession.state = .active
            currentSession.restTimeRemaining = 0
            self.session = currentSession
            haptics.success()
        } else {
            // Last exercise — finish the workout
            finishWorkout()
        }
    }

    /// Removes a set from an exercise during an active workout, keeping the
    /// active-set pointer (`currentSetNumber`) consistent. At least one set is
    /// always kept — an exercise cannot become set-less.
    func deleteSet(from exercise: Exercise, at index: Int) {
        guard var currentSession = session else { return }

        var sets = exercise.resolvedSets
        guard sets.count > 1, sets.indices.contains(index) else { return }

        undoableSet = nil
        sets.remove(at: index)
        for i in 0..<sets.count { sets[i].index = i + 1 }
        exercise.specificSets = sets
        exercise.sets = sets.count

        // Keep the active-set pointer correct, but only for the current exercise.
        let sorted = currentSession.sortedExercises
        if let exIndex = sorted.firstIndex(where: { $0.id == exercise.id }),
           exIndex == currentSession.currentExerciseIndex {
            // Deleting an already-completed set pulls the active pointer back by one.
            if index + 1 < currentSession.currentSetNumber {
                currentSession.currentSetNumber -= 1
            }
            currentSession.currentSetNumber = max(1, min(currentSession.currentSetNumber, sets.count))
            self.session = currentSession
        }

        haptics.medium()
    }

    func cancelWorkout() {
        clearRestTimer()
        session = nil
    }

    // MARK: - Internal Logic

    private func startRest(session: inout WorkoutSession, duration: Int) {
        session.state = .resting
        session.restTimeRemaining = duration
        session.originalRestDuration = duration

        targetRestEndTime = Date().addingTimeInterval(TimeInterval(duration))
        scheduleRestEndNotification(in: duration)
        if let end = targetRestEndTime {
            RestActivityController.shared.start(activityState(for: session, endDate: end))
        }

        startTicking()
    }

    func adjustRest(by seconds: Int) {
        guard var currentSession = session,
              currentSession.state == .resting else { return }

        let newTime = currentSession.restTimeRemaining + seconds
        let maxTime = currentSession.originalRestDuration + 60
        currentSession.restTimeRemaining = max(5, min(newTime, maxTime))

        // Extend originalRestDuration if user adds time (keeps bar proportion correct)
        if currentSession.restTimeRemaining > currentSession.originalRestDuration {
            currentSession.originalRestDuration = currentSession.restTimeRemaining
        }
        
        targetRestEndTime = Date().addingTimeInterval(TimeInterval(currentSession.restTimeRemaining))
        scheduleRestEndNotification(in: currentSession.restTimeRemaining)
        if let end = targetRestEndTime {
            RestActivityController.shared.update(activityState(for: currentSession, endDate: end))
        }

        self.session = currentSession
        haptics.light()
    }

    private func tick() {
        guard var currentSession = session, currentSession.state == .resting else { return }

        if let target = targetRestEndTime {
            let remaining = Int(ceil(target.timeIntervalSinceNow))
            if remaining < currentSession.restTimeRemaining {
                currentSession.restTimeRemaining = max(0, remaining)
            }
        } else {
            currentSession.restTimeRemaining -= 1
        }

        session = currentSession

        // 10 second warning
        if currentSession.restTimeRemaining == 10 {
            haptics.warning()
        }

        // 3 second countdown - haptic only
        if currentSession.restTimeRemaining == 3 {
            haptics.light()
        } else if currentSession.restTimeRemaining == 2 {
            haptics.light()
        } else if currentSession.restTimeRemaining == 1 {
            haptics.medium()
        }

        if currentSession.restTimeRemaining <= 0 {
            endRest()
        }
    }

    private func endRest() {
        clearRestTimer()
        guard var currentSession = session else { return }

        currentSession.state = .active
        session = currentSession

        // Strong haptic feedback - must be noticeable even in pocket/armband
        haptics.heavy()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startTicking() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// Stops everything a running rest owns: in-app timer, end notification, Live Activity
    private func clearRestTimer() {
        stopTimer()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RestEnd"])
        RestActivityController.shared.end()
    }

    /// Live Activity content for the current rest phase. `session` is passed
    /// explicitly because startRest works on an inout copy that is not yet
    /// published to `self.session`.
    private func activityState(for session: WorkoutSession, endDate: Date) -> RestActivityAttributes.ContentState {
        RestActivityAttributes.ContentState(
            topLabel: session.restTopLabel,
            exerciseLabel: session.restMainLabel,
            nextLabel: session.restNextLabel,
            startDate: endDate.addingTimeInterval(-TimeInterval(session.originalRestDuration)),
            endDate: endDate
        )
    }

    /// Also called directly from the end-workout dialog ("Finish & save") —
    /// persists only the sets that were actually completed.
    /// `includeActiveSet` is true for the normal flow (the final set was just checked off
    /// without advancing `currentSetNumber`) and false when ending early, where the
    /// active set was never completed.
    func finishWorkout(includeActiveSet: Bool = true) {
        clearRestTimer()
        guard var currentSession = session else { return }

        currentSession.plan.lastUsedAt = Date()
        currentSession.endedEarly = !includeActiveSet
        currentSession.state = .completed
        currentSession.endTime = Date()
        session = currentSession

        saveCompletedWorkout(currentSession)

        haptics.success()
    }

    // MARK: - History (Letztes Mal)

    /// Loads "Letztes Mal" values + previous session stats for the summary comparison
    private func loadHistory(for plan: WorkoutPlan) {
        lastResults = [:]
        previousSessionStats = nil

        guard let context = modelContext else {
            assertionFailure("WorkoutSessionManager.configure(with:) was never called — history is unavailable")
            return
        }

        let descriptor = FetchDescriptor<CompletedWorkout>(
            sortBy: [SortDescriptor(\.endTime, order: .reverse)]
        )

        let workouts: [CompletedWorkout]
        do {
            workouts = try context.fetch(descriptor)
        } catch {
            assertionFailure("Failed to fetch workout history: \(error)")
            return
        }

        for exercise in plan.exercises {
            for workout in workouts {
                if let match = workout.exercises.first(where: { $0.name == exercise.name }),
                   !match.sets.isEmpty {
                    lastResults[exercise.name] = match.sets
                    break
                }
            }
        }

        if let previous = workouts.first(where: { $0.planName == plan.name }) {
            previousSessionStats = (previous.duration, previous.totalVolume)
        }
    }

    private func saveCompletedWorkout(_ session: WorkoutSession) {
        guard let context = modelContext else {
            assertionFailure("WorkoutSessionManager.configure(with:) was never called — workout was NOT saved")
            return
        }

        let completed = CompletedWorkout(
            planName: session.plan.name,
            startTime: session.startTime,
            endTime: session.endTime ?? Date(),
            totalVolume: session.totalVolume
        )

        // Persist only sets that were actually completed (mirrors totalVolume logic)
        let sorted = session.sortedExercises
        for (index, exercise) in sorted.enumerated() {
            let sets = exercise.resolvedSets
            let completedCount: Int
            if index < session.currentExerciseIndex {
                completedCount = sets.count
            } else if index == session.currentExerciseIndex {
                completedCount = min(session.currentSetNumber - 1 + ((session.state == .completed && !session.endedEarly) ? 1 : 0), sets.count)
            } else {
                completedCount = 0
            }

            guard completedCount > 0 else { continue }

            let setData = sets.prefix(completedCount).map {
                CompletedSetData(reps: $0.reps, weight: $0.weight)
            }
            let completedExercise = CompletedExercise(
                name: exercise.name,
                orderIndex: index,
                sets: Array(setData)
            )
            completed.exercises.append(completedExercise)
        }

        context.insert(completed)
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save completed workout: \(error)")
        }
    }

    /// Called from WorkoutSummaryView to dismiss and reset
    func dismissSummary() {
        session = nil
    }

    // MARK: - Crash / kill survival

    private func persistSnapshot() {
        guard let session, session.state != .completed else {
            // No workout, or it is already saved as CompletedWorkout
            UserDefaults.standard.removeObject(forKey: Self.snapshotKey)
            lastSavedSnapshot = nil
            return
        }

        let snapshot = SessionSnapshot(
            planID: session.plan.id,
            startTime: session.startTime,
            exerciseIndex: session.currentExerciseIndex,
            setNumber: session.currentSetNumber,
            restEndTime: session.state == .resting ? targetRestEndTime : nil,
            restDuration: session.originalRestDuration
        )
        guard snapshot != lastSavedSnapshot else { return }

        do {
            UserDefaults.standard.set(try JSONEncoder().encode(snapshot), forKey: Self.snapshotKey)
            lastSavedSnapshot = snapshot
        } catch {
            assertionFailure("Failed to persist the running workout: \(error)")
        }
    }

    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: Self.snapshotKey),
              let context = modelContext else { return }

        let snapshot: SessionSnapshot
        let plan: WorkoutPlan?
        do {
            snapshot = try JSONDecoder().decode(SessionSnapshot.self, from: data)
            let planID = snapshot.planID
            plan = try context.fetch(FetchDescriptor<WorkoutPlan>(predicate: #Predicate { $0.id == planID })).first
        } catch {
            assertionFailure("Failed to restore the running workout: \(error)")
            UserDefaults.standard.removeObject(forKey: Self.snapshotKey)
            return
        }

        // The plan can't change mid-workout, so a mismatch means the snapshot is unusable
        guard let plan, plan.exercises.indices.contains(snapshot.exerciseIndex) else {
            UserDefaults.standard.removeObject(forKey: Self.snapshotKey)
            return
        }

        var restored = WorkoutSession(
            plan: plan,
            currentExerciseIndex: snapshot.exerciseIndex,
            currentSetNumber: snapshot.setNumber,
            originalRestDuration: snapshot.restDuration,
            startTime: snapshot.startTime
        )

        // A rest that ran out while the app was dead is simply over
        if let end = snapshot.restEndTime, end > Date() {
            restored.state = .resting
            restored.restTimeRemaining = Int(ceil(end.timeIntervalSinceNow))
            targetRestEndTime = end
            startTicking()
        }

        loadHistory(for: plan)
        session = restored
    }

    /// The Live Activity of a killed process is orphaned: the app start ends all
    /// of them, then puts a fresh one up if a restored rest is still running.
    func restartRestActivityIfNeeded() {
        guard let session, session.state == .resting, let end = targetRestEndTime else { return }
        RestActivityController.shared.start(activityState(for: session, endDate: end))
    }

    private func scheduleRestEndNotification(in seconds: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RestEnd"])
        guard seconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = L.notifRestOverTitle
        content.body = L.notifRestOverBody
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "RestEnd", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
