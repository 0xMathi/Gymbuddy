import SwiftUI

/// VARIANT 4: "EDITORIAL" - Magazine Style Layout
/// Bold typography-forward design like a Nike campaign
/// Large "TODAY" with workout name, editorial image placement
struct Variant4_Editorial: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with time
                HStack {
                    Text("GYM")
                        .font(.system(size: 12, weight: .black))
                        .tracking(4)
                        .foregroundStyle(Theme.Colors.accent)
                    +
                    Text("BUDDY")
                        .font(.system(size: 12, weight: .black))
                        .tracking(4)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("06:45 AM")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, 70)

                Spacer()
                    .frame(height: Theme.Spacing.xxl)

                // Editorial Hero Section
                VStack(alignment: .leading, spacing: 0) {
                    // "TODAY" in outline style
                    Text("TODAY")
                        .font(.system(size: 80, weight: .black))
                        .tracking(-2)
                        .foregroundStyle(.clear)
                        .overlay(
                            Text("TODAY")
                                .font(.system(size: 80, weight: .black))
                                .tracking(-2)
                                .foregroundStyle(.white.opacity(0.1))
                        )
                        .overlay(
                            Text("TODAY")
                                .font(.system(size: 80, weight: .black))
                                .tracking(-2)
                                .stroke(color: .white, width: 1)
                        )
                        .offset(x: isAnimating ? 0 : -30)
                        .opacity(isAnimating ? 1 : 0)

                    // Workout name
                    Text("PUSH")
                        .font(.system(size: 120, weight: .black))
                        .tracking(-4)
                        .foregroundStyle(.white)
                        .offset(y: -20)
                        .offset(x: isAnimating ? 0 : -50)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)

                    Text("DAY")
                        .font(.system(size: 120, weight: .black))
                        .tracking(-4)
                        .foregroundStyle(Theme.Colors.accent)
                        .offset(y: -40)
                        .offset(x: isAnimating ? 0 : -70)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Spacing.xl)

                // Image placeholder - editorial style
                ZStack {
                    // Simulated B&W image with orange accent
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.05)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 200)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 48))
                                        .foregroundStyle(.white.opacity(0.2))

                                    Text("B&W PHOTO")
                                        .font(.system(size: 9, weight: .medium))
                                        .tracking(2)
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                            )

                        // Orange accent strip
                        Rectangle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 8)

                        Spacer()
                    }
                }
                .frame(height: 180)
                .offset(x: isAnimating ? 0 : 100)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)

                Spacer()

                // Exercise preview
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    Text("FEATURING")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(Theme.Colors.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.medium) {
                            ExerciseChip(name: "BENCH PRESS")
                            ExerciseChip(name: "OHP")
                            ExerciseChip(name: "INCLINE DB")
                            ExerciseChip(name: "LATERAL RAISE")
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)

                Spacer()
                    .frame(height: Theme.Spacing.xl)

                // CTA
                Button(action: {}) {
                    HStack {
                        Text("BEGIN SESSION")
                            .font(.system(size: 14, weight: .black))
                            .tracking(3)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Theme.Colors.accent)
                }
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

struct ExerciseChip: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.system(size: 12, weight: .bold))
            .tracking(1)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.Colors.surface)
            .overlay(
                Rectangle()
                    .stroke(Theme.Colors.surfaceElevated, lineWidth: 1)
            )
    }
}

// Helper for stroke text
extension Text {
    func stroke(color: Color, width: CGFloat) -> some View {
        ZStack {
            self.foregroundStyle(color.opacity(0.3))
            self.offset(x: width, y: 0).foregroundStyle(.clear)
        }
    }
}

#Preview {
    Variant4_Editorial()
}
