import SwiftUI

/// Voluntary "Support GymBuddy" tip jar. Presented as a sheet from Settings.
struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = TipJarStore()

    var body: some View {
        ZStack {
            Theme.Colors.bg.ignoresSafeArea()

            if store.didThankYou {
                thankYou
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                ConfettiView().allowsHitTesting(false)
            } else {
                tipList
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.didThankYou)
        .task { await store.load() }
    }

    // MARK: - Tip list

    private var tipList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Close
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.top, Theme.Spacing.medium)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.Colors.accent)
                        .padding(.top, Theme.Spacing.small)

                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Text(L.tipTitle)
                            .font(.system(size: 32, weight: .black)).tracking(-0.5)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Text(L.tipIntro)
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: Theme.Spacing.medium) {
                        ForEach(TipJarStore.tiers) { tier in
                            tierCard(tier)
                        }
                    }
                    .padding(.top, Theme.Spacing.small)

                    if store.state == .failed {
                        Text(L.tipUnavailable)
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Text(L.tipNoUnlock)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Theme.Spacing.small)
                        .padding(.bottom, Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.xl)
            }
        }
    }

    private func tierCard(_ tier: TipJarStore.Tier) -> some View {
        Button {
            Task { await store.tip(tier) }
        } label: {
            HStack(spacing: Theme.Spacing.medium) {
                Image(systemName: tier.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.Colors.accent)
                    .frame(width: 52, height: 52)
                    .background(Theme.Colors.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusSmall))

                VStack(alignment: .leading, spacing: 2) {
                    Text(tier.name)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text(tier.subtitle)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                Spacer()

                Text(store.displayPrice(for: tier))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.Colors.bg)
                    .padding(.horizontal, Theme.Spacing.medium)
                    .frame(height: 40)
                    .background(Theme.Colors.accent)
                    .clipShape(Capsule())
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .opacity(store.isPurchasing ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(store.isPurchasing)
    }

    // MARK: - Thank you

    private var thankYou: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.Colors.accent)

            VStack(spacing: Theme.Spacing.small) {
                Text(L.tipThanksTitle)
                    .font(.system(size: 32, weight: .black)).tracking(-0.5)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Text(L.tipThanksBody)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button { dismiss() } label: {
                Text(L.tipClose)
                    .font(Theme.Fonts.bodyBold)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.bg)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Layout.buttonHeight)
                    .background(Theme.Colors.accent)
                    .cornerRadius(Theme.Layout.buttonHeight / 2)
            }
            .buttonStyle(.plain)
            .padding(.top, Theme.Spacing.medium)
            .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }
}

#Preview {
    TipJarView()
}
