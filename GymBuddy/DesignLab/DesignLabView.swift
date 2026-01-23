import SwiftUI

/// Design Lab - 5 Nike-inspired Start Screen Variations
/// Swipe through to compare, then give feedback on what you like
struct DesignLabView: View {
    @State private var currentVariant = 0

    let variants = [
        "V1: JUST DO IT",
        "V2: SPLIT CARDS",
        "V3: STATS HERO",
        "V4: EDITORIAL",
        "V5: MINIMAL POWER"
    ]

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            TabView(selection: $currentVariant) {
                Variant1_JustDoIt()
                    .tag(0)

                Variant2_SplitCards()
                    .tag(1)

                Variant3_StatsHero()
                    .tag(2)

                Variant4_Editorial()
                    .tag(3)

                Variant5_MinimalPower()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Variant Indicator
            VStack {
                HStack {
                    Text(variants[currentVariant])
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.8))
                        .cornerRadius(20)

                    Spacer()

                    // Page dots
                    HStack(spacing: 6) {
                        ForEach(0..<5) { i in
                            Circle()
                                .fill(i == currentVariant ? Theme.Colors.accent : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.8))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()
            }
        }
    }
}

#Preview {
    DesignLabView()
}
