import SwiftUI

/// VARIANT 2: "SPLIT CARDS" - Workout Type Focus
/// Three large cards for Push/Pull/Legs with workout-specific imagery
/// Each card has B&W image with orange accent on hover/selection
struct Variant2_SplitCards: View {
    @State private var selectedSplit: Int? = nil
    @State private var isAnimating = false

    let splits = [
        ("PUSH", "Chest + Shoulders + Triceps", "flame.fill"),
        ("PULL", "Back + Biceps", "arrow.down.to.line"),
        ("LEGS", "Quads + Hamstrings + Glutes", "figure.run")
    ]

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("CHOOSE YOUR")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(4)
                        .foregroundStyle(Theme.Colors.textSecondary)

                    Text("BATTLE")
                        .font(.system(size: 56, weight: .black))
                        .tracking(-1)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, 100)
                .offset(y: isAnimating ? 0 : -20)
                .opacity(isAnimating ? 1 : 0)

                Spacer()
                    .frame(height: Theme.Spacing.xl)

                // Split Cards
                VStack(spacing: Theme.Spacing.medium) {
                    ForEach(Array(splits.enumerated()), id: \.offset) { index, split in
                        SplitCard(
                            name: split.0,
                            description: split.1,
                            icon: split.2,
                            isSelected: selectedSplit == index,
                            delay: Double(index) * 0.1
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedSplit = index
                            }
                        }
                        .offset(x: isAnimating ? 0 : -50)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1 + 0.3), value: isAnimating)
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)

                Spacer()

                // Start Button (appears when selected)
                if selectedSplit != nil {
                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Text("START \(splits[selectedSplit!].0)")
                                .font(.system(size: 16, weight: .black))
                                .tracking(2)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Theme.Colors.accent)
                        .cornerRadius(0)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
                    .frame(height: Theme.Spacing.xxl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

struct SplitCard: View {
    let name: String
    let description: String
    let icon: String
    let isSelected: Bool
    let delay: Double

    var body: some View {
        HStack(spacing: Theme.Spacing.large) {
            // Placeholder for B&W workout image
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Orange overlay when selected
                if isSelected {
                    Theme.Colors.accent.opacity(0.4)
                }

                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(isSelected ? Theme.Colors.accent : .white.opacity(0.5))

                    Text("PHOTO")
                        .font(.system(size: 8, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .frame(width: 100, height: 100)

            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.system(size: 32, weight: .black))
                    .tracking(-1)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(isSelected ? Theme.Colors.accent : Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Theme.Colors.surface)
                .overlay(
                    Rectangle()
                        .fill(Theme.Colors.accent)
                        .frame(width: isSelected ? 4 : 0)
                        .animation(.spring(response: 0.3), value: isSelected),
                    alignment: .leading
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

#Preview {
    Variant2_SplitCards()
}
