import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticService.shared.medium()
            action()
        }) {
            HStack(spacing: Theme.Spacing.small) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                }
                Text(title.uppercased())
                    .font(Theme.Fonts.label)
                    .tracking(2)
            }
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Layout.buttonHeight)
            .background(Theme.Colors.accent)
            .cornerRadius(Theme.Layout.cornerRadius)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Secondary Button Style

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticService.shared.light()
            action()
        }) {
            HStack(spacing: Theme.Spacing.small) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title.uppercased())
                    .font(Theme.Fonts.label)
                    .tracking(1.5)
            }
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Layout.buttonHeightSmall)
            .background(Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusSmall)
                    .stroke(Theme.Colors.surfaceElevated, lineWidth: 2)
            )
            .cornerRadius(Theme.Layout.cornerRadiusSmall)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Theme.Colors.bg.ignoresSafeArea()
        VStack(spacing: Theme.Spacing.large) {
            PrimaryButton(title: "Start Workout", icon: "play.fill") {}
            SecondaryButton(title: "Edit Plan", icon: "pencil") {}
        }
        .padding()
    }
}
