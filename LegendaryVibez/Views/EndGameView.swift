import SwiftUI
import StoreKit

struct EndGameView: View {
    @EnvironmentObject var store: GameStore
    var onDone: () -> Void
    @State private var shareImage: Image?
    @State private var showBest = false
    @State private var bestPicked = false
    @Environment(\.requestReview) private var requestReview

    struct Award: Identifiable { let id: String; let icon: String; let winner: Player? }

    private var awards: [Award] {
        let p = store.players
        func top(_ key: (Player) -> Int) -> Player? {
            guard let m = p.max(by: { key($0) < key($1) }), key(m) > 0 else { return nil }
            return m
        }
        return [
            Award(id: "Biggest Freak",  icon: "👑", winner: top { $0.legendaryCompleted }),
            Award(id: "Most Drinks",    icon: "🍾", winner: top { $0.drinks }),
            Award(id: "Chickened Out",  icon: "🐔", winner: top { $0.chickenedOut }),
            Award(id: "Did the Most",   icon: "💪", winner: top { $0.completed }),
            Award(id: "Power Player",   icon: "⚡️", winner: top { $0.powerCardsPlayed }),
        ]
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)
            AwardsCard(awards: awards, players: store.players)
            Spacer()
            if !store.played.isEmpty {
                Button(bestPicked ? "Best card locked in" : "Pick the Best Card Tonight") { showBest = true }
                    .buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false)).disabled(bestPicked).opacity(bestPicked ? 0.5 : 1)
            }
            if let img = shareImage {
                ShareLink(item: img, preview: SharePreview("Legendary Vibez Awards", image: img)) {
                    Label("Share the Awards", systemImage: "square.and.arrow.up")
                }.buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
            }
            Button("Play Again (same crew)") { store.startGame(); Haptics.success() }.buttonStyle(LVButtonStyle())
            Button("New Game") { onDone() }.buttonStyle(LVButtonStyle(color: LVColor.grey, filled: false))
        }
        .padding(.horizontal, 24).padding(.bottom, 20)
        .onAppear {
            Haptics.success(); Sound.shared.play(.fanfare); render()
            store.markGameCompleted()
            // Ask for a rating after the second full game, once the fanfare has landed.
            if store.gamesCompleted == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { requestReview() }
            }
        }
        .sheet(isPresented: $showBest) {
            BestCardView(cards: Array(store.played.suffix(10).reversed())) { c in
                CardStats.shared.best(c); bestPicked = true; showBest = false; Sound.shared.play(.ding)
            }
        }
    }

    /// Renders a 1080x1350 story-ready version of the awards card.
    @MainActor private func render() {
        let renderer = ImageRenderer(content:
            AwardsCard(awards: awards, players: store.players, story: true)
                .frame(width: 540, height: 675)
                .background(LVColor.bg)
        )
        renderer.scale = 2
        if let ui = renderer.uiImage { shareImage = Image(uiImage: ui) }
    }
}

struct AwardsCard: View {
    let awards: [EndGameView.Award]
    let players: [Player]
    var story: Bool = false

    var body: some View {
        VStack(spacing: story ? 18 : 12) {
            if story { Spacer() }
            Text("VIBES WERE LEGENDARY").font(.caption.bold()).foregroundStyle(LVColor.gold).tracking(3)
            Text("Awards").font(.system(size: story ? 48 : 38, weight: .black)).foregroundStyle(.white)
            VStack(spacing: 10) {
                ForEach(awards) { a in
                    HStack {
                        Text(a.icon).font(.title2)
                        Text(a.id).foregroundStyle(LVColor.grey)
                        Spacer()
                        Text(a.winner.map { "\($0.emoji) \($0.name)" } ?? "Nobody").font(.headline).foregroundStyle(.white)
                    }
                    .padding(14).background(LVColor.panel).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            if story {
                Spacer()
                LogoView().scaleEffect(0.6)
                Text("Legendary Vibez on the App Store").font(.footnote).foregroundStyle(LVColor.grey)
            }
        }
        .padding(story ? 36 : 0)
    }
}

struct BestCardView: View {
    let cards: [Card]
    var onPick: (Card) -> Void
    var body: some View {
        NavigationStack {
            ZStack {
                LVColor.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 10) {
                        Text("Which card made the night?").font(.subheadline).foregroundStyle(LVColor.grey).padding(.top, 8)
                        ForEach(cards) { c in
                            Button { onPick(c) } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: c.type.symbol).foregroundStyle(c.type.accent).padding(.top, 2)
                                    Text(c.text.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: ""))
                                        .foregroundStyle(.white).multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(14).background(LVColor.panel).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }.padding(20)
                }
            }
            .navigationTitle("Best Card").navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }
}
