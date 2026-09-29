import SwiftUI

struct StoreView: View {
    @EnvironmentObject var storeKit: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LVColor.bg.ignoresSafeArea()
                VStack(spacing: 22) {
                    Spacer()
                    Image(systemName: "flame.fill").font(.system(size: 54)).foregroundStyle(LVColor.red)
                    Text("Unlock the Full Deck").font(.system(size: 30, weight: .black)).foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 10) {
                        perk("All 106 cards, every type")
                        perk("Spicy and Legendary heat levels")
                        perk("Full-length games, not just Quick")
                        perk("One-time purchase. Yours forever.")
                    }.padding(.horizontal, 8)
                    Spacer()
                    if let e = storeKit.errorMessage {
                        Text(e).font(.footnote).foregroundStyle(LVColor.grey).multilineTextAlignment(.center)
                    }
                    Button(storeKit.purchasing ? "Purchasing…" : "Unlock for \(storeKit.priceLabel)") {
                        Task { await storeKit.buy(); if storeKit.fullDeckUnlocked { Sound.shared.play(.fanfare); dismiss() } }
                    }.buttonStyle(LVButtonStyle()).disabled(storeKit.purchasing)
                    Button("Restore Purchase") { Task { await storeKit.restore(); if storeKit.fullDeckUnlocked { dismiss() } } }
                        .font(.footnote).foregroundStyle(LVColor.grey)
                }
                .padding(24)
            }
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Not now") { dismiss() }.foregroundStyle(LVColor.grey) } }
        }
    }
    private func perk(_ t: String) -> some View {
        HStack(spacing: 10) { Image(systemName: "checkmark.circle.fill").foregroundStyle(LVColor.gold); Text(t).foregroundStyle(.white) }
    }
}
