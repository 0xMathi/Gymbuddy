import SwiftUI

/// FINAL SYNTHESIS: Editorial Hero → Split Cards
/// Combines V4's massive typography with V2's workout selection cards
/// Flow: Hero section at top, scroll down to reveal Push/Pull/Legs cards
struct FinalStartScreen: View {
    @State private var isAnimating = false
    @State private var selectedSplit: Int? = nil

    let splits = [
        SplitInfo(
            name: "PUSH",
            subtitle: "CHEST & TRIS",
            muscles: "Chest + Shoulders + Triceps",
            icon: "flame.fill",
            imagePlaceholder: "Bench Press / Incline"
        ),
        SplitInfo(
            name: "PULL",
            subtitle: "BACK & BIS",
            muscles: "Back + Biceps + Rear Delts",
            icon: "arrow.down.to.line",
            imagePlaceholder: "Deadlift / Rows"
        ),
        SplitInfo(
            name: "LEGS",
            subtitle: "LOWER BODY",
            muscles: "Quads + Hamstrings + Glutes",
            icon: "figure.run",
            imagePlaceholder: "Squat / Leg Press"
        )
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // HERO SECTION - Editorial Style
                heroSection

                // SPLIT CARDS SECTION
                cardsSection
            }
        }
        .background(Theme.Colors.bg)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Hero Section (V4 Editorial Style)

    private var heroSection: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Text("GYM")
                    .font(.system(size: 11, weight: .black))
                    .tracking(4)
                    .foregroundStyle(Theme.Colors.accent)
                +
                Text("BUDDY")
                    .font(.system(size: 11, weight: .black))
                    .tracking(4)
                    .foregroundStyle(.white)

                Spacer()

                // Day indicator
                Text("MONDAY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(2)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, 60)

            Spacer()
                .frame(height: Theme.Spacing.xxxl)

            // Giant Typography
            VStack(alignment: .leading, spacing: -8) {
                Text("START")
                    .font(.system(size: 72, weight: .black))
                    .tracking(-3)
                    .foregroundStyle(.white.opacity(0.15))
                    .offset(x: isAnimating ? 0 : -40)
                    .opacity(isAnimating ? 1 : 0)

                Text("YOUR")
                    .font(.system(size: 90, weight: .black))
                    .tracking(-4)
                    .foregroundStyle(.white)
                    .offset(x: isAnimating ? 0 : -60)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)

                Text("WORK")
                    .font(.system(size: 90, weight: .black))
                    .tracking(-4)
                    .foregroundStyle(Theme.Colors.accent)
                    .offset(x: isAnimating ? 0 : -80)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)

                Text("OUT")
                    .font(.system(size: 90, weight: .black))
                    .tracking(-4)
                    .foregroundStyle(.white)
                    .offset(x: isAnimating ? 0 : -100)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.large)

            Spacer()
                .frame(height: Theme.Spacing.xxl)

            // Scroll indicator
            VStack(spacing: Theme.Spacing.small) {
                Text("SELECT YOUR SPLIT")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(Theme.Colors.textSecondary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Colors.accent)
                    .offset(y: isAnimating ? 5 : 0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            }
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.5), value: isAnimating)

            Spacer()
                .frame(height: Theme.Spacing.xxl)
        }
        .frame(minHeight: UIScreen.main.bounds.height * 0.75)
    }

    // MARK: - Cards Section (V2 Split Cards Style)

    private var cardsSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Rectangle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 40, height: 3)

                Text("CHOOSE YOUR BATTLE")
                    .font(.system(size: 12, weight: .black))
                    .tracking(3)
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.large)

            // Split Cards
            VStack(spacing: Theme.Spacing.medium) {
                ForEach(Array(splits.enumerated()), id: \.offset) { index, split in
                    WorkoutSplitCard(
                        split: split,
                        isSelected: selectedSplit == index
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSplit = index
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
                .frame(height: Theme.Spacing.xl)

            // Start Button (appears when selected)
            if let selected = selectedSplit {
                Button(action: {}) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(2)

                            Text(splits[selected].name)
                                .font(.system(size: 24, weight: .black))
                                .tracking(-1)
                        }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Theme.Colors.accent)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
                .frame(height: Theme.Spacing.xxxl)
        }
        .padding(.top, Theme.Spacing.large)
        .background(
            LinearGradient(
                colors: [Theme.Colors.bg, Theme.Colors.surface.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Supporting Types

struct SplitInfo {
    let name: String
    let subtitle: String
    let muscles: String
    let icon: String
    let imagePlaceholder: String
}

struct WorkoutSplitCard: View {
    let split: SplitInfo
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Image placeholder with orange overlay when selected
            ZStack {
                // B&W image placeholder
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Orange overlay when selected
                if isSelected {
                    Theme.Colors.accent.opacity(0.5)
                        .transition(.opacity)
                }

                // Placeholder content
                VStack(spacing: 6) {
                    Image(systemName: split.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.4))

                    Text(split.imagePlaceholder)
                        .font(.system(size: 8, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 110, height: 110)

            // Orange accent bar
            Rectangle()
                .fill(isSelected ? Theme.Colors.accent : Theme.Colors.surfaceElevated)
                .frame(width: isSelected ? 4 : 2)
                .animation(.spring(response: 0.3), value: isSelected)

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(split.subtitle)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(Theme.Colors.textSecondary)

                Text(split.name)
                    .font(.system(size: 36, weight: .black))
                    .tracking(-2)
                    .foregroundStyle(.white)

                Text(split.muscles)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.leading, Theme.Spacing.medium)

            Spacer()

            // Selection indicator
            ZStack {
                Circle()
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.surfaceElevated, lineWidth: 2)
                    .frame(width: 24, height: 24)

                if isSelected {
                    Circle()
                        .fill(Theme.Colors.accent)
                        .frame(width: 14, height: 14)
                        .transition(.scale)
                }
            }
            .padding(.trailing, Theme.Spacing.large)
        }
        .background(Theme.Colors.surface)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    FinalStartScreen()
}
