import SwiftUI
import UniformTypeIdentifiers

struct PlayerSetupView: View {
    @EnvironmentObject var store: GameStore
    @EnvironmentObject var storeKit: StoreManager
    @State private var showStore = false
    @State private var newName = ""
    @State private var goToGame = false
    @FocusState private var nameFocused: Bool
    @State private var dragging: Player?

    private let emojis = ["🔥","😈","🍑","🍒","💋","🍾","👑","🌶️","🍹","😏","💦","🎲"]

    var body: some View {
        ZStack {
            LVColor.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    section("PLAYERS  ·  seating order, clockwise  ·  hold to reorder") {
                        ForEach(store.players) { p in
                            HStack {
                                Text(p.emoji).font(.title2)
                                Text(p.name).foregroundStyle(.white).font(.body.weight(.semibold))
                                Spacer()
                                Image(systemName: "line.3.horizontal").foregroundStyle(LVColor.line)
                                Button { withAnimation { store.players.removeAll { $0.id == p.id } } } label: {
                                    Image(systemName: "xmark.circle.fill").foregroundStyle(LVColor.grey)
                                }
                            }
                            .padding(12).background(LVColor.panel).clipShape(RoundedRectangle(cornerRadius: 12))
                            .onDrag { dragging = p; return NSItemProvider(object: p.name as NSString) }
                            .onDrop(of: [.text], delegate: ReorderDrop(item: p, items: $store.players, dragging: $dragging))
                        }
                        HStack {
                            TextField("Add player", text: $newName)
                                .focused($nameFocused)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                                .onSubmit(addPlayer)
                                .padding(12).background(LVColor.panel).clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)
                            Button(action: addPlayer) {
                                Image(systemName: "plus").font(.title3.bold()).foregroundStyle(.white)
                                    .frame(width: 46, height: 46).background(LVColor.red).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        if store.players.count < 2 {
                            Text("Add at least 2 players.").font(.footnote).foregroundStyle(LVColor.grey)
                        }
                    }

                    section("HEAT") {
                        ForEach(Heat.allCases) { h in
                            let locked = !storeKit.fullDeckUnlocked && h != .chill
                            Button {
                                if locked { showStore = true } else { store.settings.heat = h; Haptics.tap() }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(h.title).font(.headline).foregroundStyle(.white)
                                        Text(h.blurb).font(.caption).foregroundStyle(LVColor.grey)
                                    }
                                    Spacer()
                                    if locked { Image(systemName: "lock.fill").foregroundStyle(LVColor.gold) }
                                    HStack(spacing: 3) {
                                        ForEach(1...3, id: \.self) { i in
                                            Image(systemName: "flame.fill").font(.caption)
                                                .foregroundStyle(i <= h.rawValue ? LVColor.red : LVColor.line)
                                        }
                                    }
                                }
                                .padding(14)
                                .background(LVColor.panel)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(store.settings.heat == h ? LVColor.red : .clear, lineWidth: 2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    section("DRINK MODE") {
                        Picker("", selection: $store.settings.drinkMode) {
                            ForEach(DrinkMode.allCases) { Text($0.title).tag($0) }
                        }.pickerStyle(.segmented)
                    }

                    section("DECK") {
                        if storeKit.fullDeckUnlocked {
                            Picker("", selection: $store.settings.deckSize) {
                                ForEach(DeckSize.allCases) { Text($0.title).tag($0) }
                            }.pickerStyle(.segmented)
                        } else {
                            Button { showStore = true } label: {
                                HStack {
                                    Text("Quick (30 cards)").foregroundStyle(.white)
                                    Spacer()
                                    Label("Unlock Full Deck · \(storeKit.priceLabel)", systemImage: "lock.fill").font(.caption.bold()).foregroundStyle(LVColor.gold)
                                }.padding(14).background(LVColor.panel).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    Button("Start the Vibez") {
                        if !storeKit.fullDeckUnlocked { store.settings.heat = .chill; store.settings.deckSize = .quick }
                        store.startGame(); Haptics.success(); Sound.shared.play(.ding); goToGame = true
                    }
                    .buttonStyle(LVButtonStyle())
                    .disabled(store.players.count < 2)
                    .opacity(store.players.count < 2 ? 0.4 : 1)
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .navigationTitle("Set Up")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToGame) { GameView() }
        .sheet(isPresented: $showStore) { StoreView() }
    }

    private func addPlayer() {
        let n = newName.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty, store.players.count < 12 else { return }
        store.players.append(Player(name: n, emoji: emojis[store.players.count % emojis.count]))
        newName = ""; Haptics.tap(); nameFocused = true
    }

    @ViewBuilder private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption.bold()).foregroundStyle(LVColor.gold).tracking(1.5)
            content()
        }
    }
}

/// Minimal drag-to-reorder for the player list.
struct ReorderDrop: DropDelegate {
    let item: Player
    @Binding var items: [Player]
    @Binding var dragging: Player?

    func dropEntered(info: DropInfo) {
        guard let d = dragging, d != item,
              let from = items.firstIndex(of: d), let to = items.firstIndex(of: item) else { return }
        withAnimation { items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to) }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
    func performDrop(info: DropInfo) -> Bool { dragging = nil; return true }
}
