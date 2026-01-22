import SwiftUI

struct RestTimerView: View {
    let timeRemaining: Int
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Theme.Colors.bg.opacity(0.95)
                .ignoresSafeArea()
                .onTapGesture {
                    onSkip()
                }
            
            VStack(spacing: Theme.Spacing.xxl) {
                Text("REST")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .tracking(2)
                
                // Timer Text
                Text(timeString(from: timeRemaining))
                    .font(Theme.Fonts.hero.monospacedDigit())
                    .foregroundStyle(timeRemaining <= 10 ? Theme.Colors.destructive : Theme.Colors.textPrimary)
                    .scaleEffect(timeRemaining <= 10 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: timeRemaining)
                
                // Hint
                Text("Tap to skip")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .opacity(0.6)
                
                // Explicit Button
                Button(action: onSkip) {
                    Text("SKIP")
                        .font(Theme.Fonts.h3)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .padding(.horizontal, Theme.Spacing.xxl)
                        .padding(.vertical, Theme.Spacing.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.Colors.surfaceElevated, lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    RestTimerView(timeRemaining: 45, onSkip: {})
}
