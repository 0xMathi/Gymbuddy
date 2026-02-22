import SwiftUI

/// Inline rest timer bar with countdown number, depleting progress bar, and ±15s adjustment buttons.
/// Replaces the full-screen RestTimerView overlay.
struct RestTimerBar: View {
    let timeRemaining: Int
    let totalDuration: Int
    let onAdjust: (Int) -> Void

    @State private var animatedProgress: Double = 1.0

    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalDuration)
    }

    private var isWarning: Bool { timeRemaining <= 10 }

    private var barColor: Color {
        isWarning ? Theme.Colors.destructive : Theme.Colors.accent
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            // Countdown number
            Text(timeString(from: timeRemaining))
                .font(.system(size: 80, weight: .black, design: .monospaced))
                .foregroundStyle(isWarning ? Theme.Colors.destructive : Theme.Colors.textPrimary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: timeRemaining)

            // Progress bar + ±15s buttons
            HStack(spacing: Theme.Spacing.medium) {
                adjustButton(label: "−15", seconds: -15)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.Colors.surfaceElevated)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor)
                            .frame(width: max(0, geo.size.width * animatedProgress), height: 8)
                            .animation(.linear(duration: 1.0), value: animatedProgress)
                    }
                }
                .frame(height: 8)

                adjustButton(label: "+15", seconds: +15)
            }
        }
        .onChange(of: timeRemaining) { _, _ in
            animatedProgress = progress
        }
        .onAppear {
            animatedProgress = progress
        }
    }

    // MARK: - Adjust Button

    private func adjustButton(label: String, seconds: Int) -> some View {
        Button {
            onAdjust(seconds)
        } label: {
            Text(label)
                .font(Theme.Fonts.label)
                .tracking(0.5)
                .foregroundStyle(Theme.Colors.textSecondary)
                .frame(width: 52, height: 40)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.Layout.cornerRadiusSmall)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : "\(s)"
    }
}

// MARK: - Previews

#Preview("Normal State") {
    ZStack {
        Theme.Colors.bg.ignoresSafeArea()
        RestTimerBar(timeRemaining: 45, totalDuration: 90) { _ in }
            .padding(Theme.Spacing.xl)
    }
}

#Preview("Warning State") {
    ZStack {
        Theme.Colors.bg.ignoresSafeArea()
        RestTimerBar(timeRemaining: 8, totalDuration: 90) { _ in }
            .padding(Theme.Spacing.xl)
    }
}
