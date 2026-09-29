import SwiftUI

/// Drives one turn: Pass screen -> Card -> (mechanic) -> Done / Drink -> next player.
struct GameView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var revealed = false
    @State private var chosen: Player? = nil
    @State private var showRoster = false
    @State private var showHand = false
    @State private var showRate = false
    @State private var showEnd = false

    private var gameOver: Bool { store.players.isEmpty || store.deck.isEmpty }

    var body: some View {
        ZStack {
            LVColor.bg.ignoresSafeArea()
            if gameOver {
                EndGameView(onDone: { store.endGame(); dismiss() })
                    .transition(.opacity)
            } else if !revealed {
                PassView(player: store.currentPlayer, cardsLeft: store.cardsLeft, totalCards: store.totalCards,
                         drinkWord: store.settings.drinkMode.plural,
                         onReveal: reveal, onOpenHand: { showHand = true })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if let card = store.drawCard() {
                CardScreen(card: card, chosen: $chosen, showRoster: $showRoster, showRate: $showRate,
                           onDone: { store.complete(card: card); Sound.shared.play(.ding); nextTurn() },
                           onDrink: { store.drinkInstead(card: card); Sound.shared.play(.drink); nextTurn() },
                           onKeep: { store.keep(card: card); nextTurn() })
                    .id(card.id)
                    .transition(.asymmetric(insertion: .scale(scale: 0.85).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
        .toolbar {
            if !gameOver {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("End") { showEnd = true }.foregroundStyle(LVColor.grey)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("End the game?", isPresented: $showEnd, titleVisibility: .visible) {
            Button("Show Awards", role: .destructive) { withAnimation { store.deck = [] } }
            Button("Keep Playing", role: .cancel) {}
        }
        .sheet(isPresented: $showRoster) {
            RosterPickerView(players: store.players.filter { $0.id != store.currentPlayer.id }) { p in
                chosen = p; showRoster = false; Haptics.tap()
            }
        }
        .sheet(isPresented: $showHand) { PowerHandView() }
        .sheet(isPresented: $showRate) { RateAllView(players: store.players.filter { $0.id != store.currentPlayer.id }) }
    }

    private func reveal() {
        Haptics.draw(); Sound.shared.play(.flip)
        store.lockRandomTarget()
        withAnimation(.spring(duration: 0.5, bounce: 0.25)) { revealed = true }
    }

    private func nextTurn() {
        Haptics.success()
        chosen = nil
        withAnimation(.easeInOut(duration: 0.3)) { revealed = false }
    }
}

struct PassView: View {
    let player: Player
    let cardsLeft: Int
    let totalCards: Int
    let drinkWord: String
    var onReveal: () -> Void
    var onOpenHand: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            ProgressBar(progress: totalCards == 0 ? 0 : Double(totalCards - cardsLeft) / Double(totalCards))
            Spacer()
            Text("PASS THE PHONE TO").font(.caption.bold()).foregroundStyle(LVColor.gold).tracking(3)
            Text(player.emoji).font(.system(size: 84))
            Text(player.name).font(.system(size: 42, weight: .black)).foregroundStyle(.white)
                .minimumScaleFactor(0.5).lineLimit(1).padding(.horizontal)
            HStack(spacing: 14) {
                stat("\(player.drinks)", drinkWord)
                stat("\(player.completed)", "done")
                stat("\(player.chickenedOut)", "skipped")
            }
            Spacer()
            if !player.hand.isEmpty {
                Button { onOpenHand() } label: {
                    Label("\(player.hand.count) Power card\(player.hand.count == 1 ? "" : "s") in hand", systemImage: "crown.fill")
                }.buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
            }
            Button("Tap to Draw") { onReveal() }.buttonStyle(LVButtonStyle())
            Text("\(cardsLeft) cards left").font(.footnote).foregroundStyle(LVColor.grey)
        }
        .padding(.horizontal, 28).padding(.bottom, 16)
        .contentShape(Rectangle())
        .onTapGesture { onReveal() }
    }

    private func stat(_ n: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(n).font(.title3.bold()).foregroundStyle(.white)
            Text(label).font(.caption2).foregroundStyle(LVColor.grey)
        }.frame(minWidth: 64)
    }
}

struct ProgressBar: View {
    let progress: Double
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(LVColor.line)
                Capsule().fill(LinearGradient(colors: [LVColor.red, LVColor.gold], startPoint: .leading, endPoint: .trailing))
                    .frame(width: g.size.width * progress)
                    .animation(.easeOut(duration: 0.4), value: progress)
            }
        }.frame(height: 4)
    }
}

struct CardScreen: View {
    @EnvironmentObject var store: GameStore
    let card: Card
    @Binding var chosen: Player?
    @Binding var showRoster: Bool
    @Binding var showRate: Bool
    var onDone: () -> Void
    var onDrink: () -> Void
    var onKeep: () -> Void

    @State private var mechanicDone = false
    @State private var flipped = false

    private var resolver: TextResolver {
        TextResolver(players: store.players, currentIndex: store.currentIndex,
                     drinkMode: store.settings.drinkMode, chosen: chosen, random: store.randomTarget)
    }
    private var needsChoice: Bool { card.needsChosenPlayer && chosen == nil }
    private var mode: DrinkMode { store.settings.drinkMode }
    private var showsDrinkAlt: Bool { card.type != .power && card.type != .drink }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(store.currentPlayer.emoji + " " + store.currentPlayer.name).font(.subheadline.bold()).foregroundStyle(LVColor.grey)
                Spacer()
                HeatFlames(level: card.heat)
            }

            ZStack {
                CardFrame(color: card.type.accent)
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Image(systemName: card.type.symbol).font(.title2).foregroundStyle(card.type.accent)
                        Text(card.type.label).font(.system(size: 15, weight: .black, design: .serif)).foregroundStyle(.white).tracking(2)
                        Rectangle().fill(card.type.accent).frame(width: 60, height: 1.5)
                    }
                    Text(resolver.resolve(card.text))
                        .font(.system(size: 26, weight: .medium, design: .serif))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                        .minimumScaleFactor(0.55).padding(.horizontal, 22)
                        .contentTransition(.opacity)
                    if showsDrinkAlt {
                        Text("or take \(card.drink_alt) \(card.drink_alt == 1 ? mode.singular : mode.plural)")
                            .font(.footnote.italic()).foregroundStyle(LVColor.grey)
                    }
                }.padding(.vertical, 30)
                .opacity(flipped ? 1 : 0)
            }
            .frame(maxHeight: .infinity)
            .rotation3DEffect(.degrees(flipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .onAppear { withAnimation(.spring(duration: 0.55, bounce: 0.2)) { flipped = true } }

            if flipped {
                MechanicView(card: card, done: $mechanicDone)

                if card.mechanic == .rate_all {
                    Button("Open the Ratings") { showRate = true }.buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
                }

                if needsChoice {
                    Button("Choose a Player") { showRoster = true }.buttonStyle(LVButtonStyle(color: LVColor.gold))
                } else if card.type == .power {
                    HStack(spacing: 12) {
                        Button("Use Now") { onDone() }.buttonStyle(LVButtonStyle(color: LVColor.gold))
                        if card.mechanic == .skip {
                            Button("Keep It") { onKeep() }.buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
                        }
                    }
                } else {
                    HStack(spacing: 12) {
                        Button("Done") { onDone() }.buttonStyle(LVButtonStyle())
                        Button(mode.verb) { onDrink() }.buttonStyle(LVButtonStyle(color: LVColor.grey, filled: false))
                    }
                }
            }
        }
        .padding(.horizontal, 20).padding(.bottom, 20)
    }
}

struct HeatFlames: View {
    let level: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...3, id: \.self) { i in
                Image(systemName: "flame.fill").font(.caption2).foregroundStyle(i <= level ? LVColor.red : LVColor.line)
            }
        }
    }
}
