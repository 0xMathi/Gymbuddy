import ActivityKit
import WidgetKit
import SwiftUI

/// Rest-timer Live Activity: lock screen banner + Dynamic Island.
/// The system drives the countdown itself via `Text(timerInterval:)` /
/// `ProgressView(timerInterval:)` — the app only pushes start/adjust/pause/end.
/// Three visual states: counting down, paused (frozen time), and stale
/// (rest ran out while the app was in the background → "GO!").
struct RestTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestActivityAttributes.self) { context in
            LockScreenRestView(context: context)
                .activityBackgroundTint(Theme.Colors.bg.opacity(0.96))
                .activitySystemActionForegroundColor(Theme.Colors.accent)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.isStale ? "GO!" : context.state.topLabel)
                            .font(.system(size: 12, weight: .black))
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.accent)
                        Text(context.state.exerciseLabel)
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    RestCountdown(context: context, size: 28)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        RestProgressBar(context: context)
                        HStack {
                            if let next = context.state.nextLabel {
                                Text(next)
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(Theme.Colors.textSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            Spacer(minLength: 12)
                            SkipButton(label: context.attributes.skipLabel)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 6)
                }
            } compactLeading: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(Theme.Colors.accent)
            } compactTrailing: {
                RestCountdown(context: context, size: 14)
                    .frame(maxWidth: 46)
            } minimal: {
                if context.isStale {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(Theme.Colors.accent)
                } else {
                    ProgressView(
                        timerInterval: context.state.startDate...context.state.endDate,
                        countsDown: true
                    ) {
                    } currentValueLabel: {
                    }
                    .progressViewStyle(.circular)
                    .tint(Theme.Colors.accent)
                }
            }
            .keylineTint(Theme.Colors.accent)
        }
    }
}

// MARK: - Lock screen banner

private struct LockScreenRestView: View {
    let context: ActivityViewContext<RestActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(context.isStale ? "GO!" : context.state.topLabel)
                        .font(.system(size: 12, weight: .black))
                        .tracking(1.5)
                        .foregroundStyle(Theme.Colors.accent)
                    Text(context.state.exerciseLabel)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }

                Spacer(minLength: 12)

                RestCountdown(context: context, size: 32)
            }

            RestProgressBar(context: context)

            HStack {
                if let next = context.state.nextLabel {
                    Text(next)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 12)
                SkipButton(label: context.attributes.skipLabel)
            }
        }
        .padding(16)
    }
}

// MARK: - Shared pieces

/// Countdown number: live system timer, 0:00 when stale.
private struct RestCountdown: View {
    let context: ActivityViewContext<RestActivityAttributes>
    let size: CGFloat

    var body: some View {
        if context.isStale {
            Text("0:00")
                .font(.system(size: size, weight: .black, design: .monospaced))
                .foregroundStyle(Theme.Colors.accent)
        } else {
            Text(
                timerInterval: context.state.startDate...context.state.endDate,
                countsDown: true,
                showsHours: false
            )
            .font(.system(size: size, weight: .black, design: .monospaced))
            .foregroundStyle(Theme.Colors.accent)
            .multilineTextAlignment(.trailing)
        }
    }
}

/// Depleting progress bar, mirroring the in-app rest bar.
private struct RestProgressBar: View {
    let context: ActivityViewContext<RestActivityAttributes>

    var body: some View {
        Group {
            if context.isStale {
                ProgressView(value: 0, total: 1)
            } else {
                ProgressView(
                    timerInterval: context.state.startDate...context.state.endDate,
                    countsDown: true
                ) {
                } currentValueLabel: {
                }
            }
        }
        .progressViewStyle(.linear)
        .tint(Theme.Colors.accent)
    }
}

private struct SkipButton: View {
    let label: String

    var body: some View {
        Button(intent: SkipRestIntent()) {
            Text(label)
                .font(.system(size: 12, weight: .black))
                .tracking(1)
                .foregroundStyle(Theme.Colors.bg)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.Colors.accent))
        }
        .buttonStyle(.plain)
    }
}
