import Foundation
import ActivityKit

/// Owns the one rest-timer Live Activity. One activity exists per rest phase:
/// it appears when rest starts and disappears when rest ends, is skipped, or
/// the workout finishes. The system renders the countdown itself
/// (`Text(timerInterval:)`), so no ticking updates are needed — only
/// start / adjust / end transitions.
/// All calls come from the main thread (UI actions + main-runloop timer).
final class RestActivityController {
    static let shared = RestActivityController()

    private var activity: Activity<RestActivityAttributes>?

    private init() {}

    /// Called when a rest phase begins. Reuses the running activity if one
    /// exists (e.g. rapid set → rest → set flows) instead of flickering.
    func start(_ state: RestActivityAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let content = ActivityContent(state: state, staleDate: state.endDate)
        if let activity {
            Task { await activity.update(content) }
            return
        }

        do {
            activity = try Activity.request(
                attributes: RestActivityAttributes(skipLabel: L.skip),
                content: content
            )
        } catch {
            // Live Activities can fail to start (user disabled them, system limit).
            // The in-app timer and the rest-end notification still work — no fallback needed.
        }
    }

    /// Pushes a new state (±15s adjustment). No-op when no activity runs.
    func update(_ state: RestActivityAttributes.ContentState) {
        guard let activity else { return }
        let content = ActivityContent(state: state, staleDate: state.endDate)
        Task { await activity.update(content) }
    }

    /// Ends the current activity immediately (rest over, skipped, workout ended).
    func end() {
        guard let activity else { return }
        self.activity = nil
        let finalContent = ActivityContent(state: activity.content.state, staleDate: nil)
        Task { await activity.end(finalContent, dismissalPolicy: .immediate) }
    }

    /// App-start cleanup: removes activities that survived a force-quit or crash.
    /// Their process is gone, so none of them can be updated or ended anymore.
    func endAllStale() async {
        // Skips the one this process owns, should this ever run again mid-workout
        for stale in Activity<RestActivityAttributes>.activities where stale.id != activity?.id {
            await stale.end(nil, dismissalPolicy: .immediate)
        }
    }
}
