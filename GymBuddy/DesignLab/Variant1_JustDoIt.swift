import SwiftUI

/// VARIANT 1: "JUST DO IT" - Full Bleed Hero
/// Full-screen B&W athlete image with massive overlaid typography
/// Orange gradient at bottom, single bold CTA
struct Variant1_JustDoIt: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background - Simulated B&W Hero Image
            heroImagePlaceholder

            // Orange gradient overlay from bottom
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        .clear,
                        Theme.Colors.accent.opacity(0.3),
                        Theme.Colors.accent.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 400)
            }
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Main Typography
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("START")
                        .font(.system(size: 72, weight: .black))
                        .tracking(-2)

                    Text("YOUR")
                        .font(.system(size: 72, weight: .black))
                        .tracking(-2)

                    Text("WORKOUT")
                        .font(.system(size: 72, weight: .black))
                        .tracking(-2)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Spacing.xl)
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)

                Spacer()
                    .frame(height: Theme.Spacing.xxxl)

                // CTA Button
                Button(action: {}) {
                    HStack(spacing: 12) {
                        Text("LET'S GO")
                            .font(.system(size: 18, weight: .black))
                            .tracking(3)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundStyle(Theme.Colors.bg)
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background(.white)
                    .cornerRadius(0) // Nike style - no rounded corners
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
    }

    // Simulated B&W athlete image with geometric shapes
    private var heroImagePlaceholder: some View {
        ZStack {
            // Dark base
            Color.black

            // Simulated athlete silhouette (geometric representation)
            GeometryReader { geo in
                // Background texture
                ForEach(0..<20) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.02))
                        .frame(width: geo.size.width, height: 2)
                        .offset(y: CGFloat(i) * 40)
                }

                // Abstract athlete shape
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height

                    // Simplified human form doing bench press
                    path.move(to: CGPoint(x: w * 0.3, y: h * 0.3))
                    path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.25))
                    path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.4))
                    path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.4))
                    path.closeSubpath()
                }
                .fill(Color.white.opacity(0.08))

                // "PUSH DAY" label
                VStack {
                    HStack {
                        Spacer()
                        Text("PUSH DAY")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .tracking(4)
                            .foregroundStyle(Theme.Colors.accent)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Theme.Colors.bg.opacity(0.9))
                    }
                    .padding(.top, 100)
                    .padding(.trailing, 20)
                    Spacer()
                }

                // Placeholder text for image
                VStack {
                    Spacer()
                        .frame(height: geo.size.height * 0.15)
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.2))
                            Text("B&W ATHLETE PHOTO")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.3))
                            Text("Bench Press / Chest Focus")
                                .font(.system(size: 9, weight: .regular))
                                .foregroundStyle(.white.opacity(0.2))
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    Variant1_JustDoIt()
}
