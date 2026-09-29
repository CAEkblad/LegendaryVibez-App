import Foundation
import Combine
import StoreKit

/// StoreKit 2. One non-consumable at launch: the Full Deck unlock.
/// Free tier: Chill heat + Quick deck. Unlock: all heat levels + full deck.
/// Phase 2 adds pack products here; the gating pattern stays the same.
@MainActor
final class StoreManager: ObservableObject {
    static let fullDeckID = "com.legendaryvibez.fulldeck"   // must match App Store Connect + Products.storekit

    @Published private(set) var fullDeckUnlocked: Bool = UserDefaults.standard.bool(forKey: "fullDeckUnlocked")
    @Published private(set) var product: Product?
    @Published var purchasing = false
    @Published var errorMessage: String?

    private var updates: Task<Void, Never>?

    init() {
        #if DEBUG
        // Flip to true to skip the paywall while developing. Never ship true.
        let debugUnlockAll = false
        fullDeckUnlocked = fullDeckUnlocked || debugUnlockAll
        #endif
        updates = Task { await listenForTransactions() }
        Task { await load(); await refreshEntitlements() }
    }
    deinit { updates?.cancel() }

    var priceLabel: String { product?.displayPrice ?? "$4.99" }

    func load() async {
        do { product = try await Product.products(for: [Self.fullDeckID]).first }
        catch { errorMessage = "Store unavailable. Try again in a moment." }
    }

    func buy() async {
        guard let product else { await load(); return }
        purchasing = true; defer { purchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                if case .verified(let tx) = verification { unlock(); await tx.finish() }
            case .userCancelled, .pending: break
            @unknown default: break
            }
        } catch { errorMessage = "Purchase failed. You weren't charged." }
    }

    func restore() async {
        try? await StoreKit.AppStore.sync()
        await refreshEntitlements()
        if !fullDeckUnlocked { errorMessage = "No previous purchase found for this Apple ID." }
    }

    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == Self.fullDeckID, tx.revocationDate == nil { unlock() }
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let tx) = result {
                if tx.productID == Self.fullDeckID { unlock() }
                await tx.finish()
            }
        }
    }

    private func unlock() {
        fullDeckUnlocked = true
        UserDefaults.standard.set(true, forKey: "fullDeckUnlocked")
    }
}
