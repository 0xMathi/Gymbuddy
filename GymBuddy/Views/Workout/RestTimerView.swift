import SwiftUI

struct RestTimerView: View {
    let timeRemaining: Int
    let onSkip: () -> Void

    private var isWarning: Bool { timeRemaining <= 10 }

    var body: some View {
        ZStack {
            // Full screen dark overlay
            Theme.Colors.bg.opacity(0.97)
                .ignoresSafeArea()
                .onTapGesture {
                    onSkip()
                }

            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                // REST Label
                Text("REST")
                    .font(Theme.Fonts.label)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .tracking(4)

                // Giant Timer
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 120, weight: .black, design: .monospaced))
                    .foregroundStyle(isWarning ? Theme.Colors.destructive : Theme.Colors.accent)
                    .scaleEffect(isWarning ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: timeRemaining)
                    .shadow(color: (isWarning ? Theme.Colors.destructive : Theme.Colors.accent).opacity(0.3), radius: 20)

                // Progress indicator
                if !isWarning {
                    Text("GET READY")
                        .font(Theme.Fonts.body)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .tracking(2)
                } else {
                    Text("ALMOST THERE")
                        .font(Theme.Fonts.bodyBold)
                        .foregroundStyle(Theme.Colors.destructive)
                        .tracking(2)
                }

                Spacer()

                // Skip Button
                Button(action: {
                    HapticService.shared.light()
                    onSkip()
                }) {
                    HStack(spacing: Theme.Spacing.small) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("SKIP REST")
                            .font(Theme.Fonts.label)
                            .tracking(2)
                    }
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Layout.buttonHeightSmall)
                    .background(Theme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusSmall)
                            .stroke(Theme.Colors.surfaceElevated, lineWidth: 2)
                    )
                    .cornerRadius(Theme.Layout.cornerRadiusSmall)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
        return "\(remainingSeconds)"
    }
}

#Preview {
    RestTimerView(timeRemaining: 45, onSkip: {})
}

#Preview("Warning State") {
    RestTimerView(timeRemaining: 8, onSkip: {})
}
