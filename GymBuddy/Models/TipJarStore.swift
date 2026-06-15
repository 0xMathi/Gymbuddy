import Foundation
import StoreKit
import Observation

/// Voluntary tip jar backed by StoreKit 2 consumables. Nothing is unlocked — goodwill only.
@Observable
@MainActor
final class TipJarStore {
    enum LoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    /// Tip tiers (display is app-defined; price comes from StoreKit when available).
    struct Tier: Identifiable {
        let id: String          // StoreKit product ID
        let name: String        // gym-themed, English in both languages
        let subtitle: String    // localized flavor line
        let fallbackPrice: String
        let icon: String        // SF Symbol
    }

    static let tiers: [Tier] = [
        Tier(id: "com.mathis.GymBuddy.tip.preworkout",
             name: "Pre-Workout", subtitle: L.tipSubSmall, fallbackPrice: "€1.99", icon: "bolt.fill"),
        Tier(id: "com.mathis.GymBuddy.tip.proteinshake",
             name: "Protein Shake", subtitle: L.tipSubMedium, fallbackPrice: "€4.99", icon: "waterbottle.fill"),
        Tier(id: "com.mathis.GymBuddy.tip.cheatmeal",
             name: "Cheat Meal", subtitle: L.tipSubLarge, fallbackPrice: "€9.99", icon: "fork.knife"),
    ]

    private(set) var state: LoadState = .loading
    private(set) var products: [String: Product] = [:]   // keyed by product ID
    var isPurchasing = false
    var didThankYou = false

    nonisolated(unsafe) private var updatesTask: Task<Void, Never>?

    init() {
        // Finish any transactions that arrive outside an explicit purchase (e.g. Ask to Buy).
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await MainActor.run { self?.didThankYou = true }
                }
            }
        }
    }

    deinit { updatesTask?.cancel() }

    func load() async {
        state = .loading
        do {
            let loaded = try await Product.products(for: Self.tiers.map(\.id))
            products = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
            state = loaded.isEmpty ? .failed : .loaded
        } catch {
            state = .failed
        }
    }

    /// Localized price for a tier, falling back to the static label when StoreKit is unavailable.
    func displayPrice(for tier: Tier) -> String {
        products[tier.id]?.displayPrice ?? tier.fallbackPrice
    }

    func tip(_ tier: Tier) async {
        guard let product = products[tier.id], !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await transaction.finish()
                HapticService.shared.success()
                didThankYou = true
            }
            // .userCancelled / .pending / failed verification → quietly return to the cards
        } catch {
            // Network or StoreKit error → no scary alert, just stay on the cards.
        }
    }
}
