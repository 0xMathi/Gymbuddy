import Foundation
import ActivityKit

/// Shared between the app and the widget extension (member of both targets).
/// All strings arrive pre-localized from the app: the extension has no access
/// to the runtime `L` enum, and exercise names are localized via
/// ExerciseLocalization on the app side anyway.
struct RestActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// "REST · SET 3" / "PAUSE · SATZ 3"
        var topLabel: String
        /// Exercise the athlete is resting for, uppercased ("BENCH PRESS")
        var exerciseLabel: String
        /// "THEN: INCLINE PRESS" — nil when nothing follows
        var nextLabel: String?
        /// endDate minus the full rest duration — anchors the depleting progress bar
        var startDate: Date
        /// Wall-clock end of the rest; the system counts down on its own
        var endDate: Date
    }

    // Static per activity, pre-localized once at start
    var skipLabel: String
}
