import Foundation
import Combine
import SwiftUI

/// Single source of truth for the running game. Persisted so an incoming call doesn't wipe the session.
final class GameStore: ObservableObject {
    @Published var players: [Player] = []
    @Published var settings = GameSettings()
    @Published var deck: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var turn: Int = 0
    @Published var inGame: Bool = false
    @Published var totalCards: Int = 0
    /// Cards played this game, most recent last. Feeds the "best card tonight" pick.
    @Published var played: [Card] = []
    @Published var gamesCompleted: Int = UserDefaults.standard.integer(forKey: "gamesCompleted")
    /// Locked in when a card is revealed so {random} doesn't re-roll on every redraw.
    @Published var randomTarget: Player? = nil

    let packs: [Pack]

    init() {
        packs = ["base"].compactMap { DeckLoader.load(packID: $0) }
        restore()
    }

    var currentPlayer: Player { players[currentIndex] }
    var cardsLeft: Int { deck.count }

    func startGame() {
        for i in players.indices {
            players[i].drinks = 0; players[i].completed = 0; players[i].chickenedOut = 0
            players[i].legendaryCompleted = 0; players[i].powerCardsPlayed = 0; players[i].hand = []
        }
        deck = DeckBuilder.build(settings: settings, packs: packs)
        totalCards = deck.count
        played = []
        currentIndex = 0
        turn = 0
        inGame = true
        persist()
    }

    func drawCard() -> Card? { deck.first }

    /// Call once when a card is revealed.
    func lockRandomTarget() {
        let others = players.enumerated().filter { $0.offset != currentIndex }.map { $0.element }
        randomTarget = others.randomElement()
    }

    func complete(card: Card) {
        CardStats.shared.record(card, done: true); played.append(card)
        players[currentIndex].completed += 1
        if card.heat == 3 { players[currentIndex].legendaryCompleted += 1 }
        finishTurn()
    }

    func drinkInstead(card: Card) {
        CardStats.shared.record(card, done: false); played.append(card)
        players[currentIndex].chickenedOut += 1
        players[currentIndex].drinks += card.drink_alt
        finishTurn()
    }

    /// Player pockets a Power card to use later.
    func keep(card: Card) {
        players[currentIndex].hand.append(card)
        finishTurn()
    }

    func playFromHand(card: Card) {
        players[currentIndex].hand.removeAll { $0.id == card.id }
        players[currentIndex].powerCardsPlayed += 1
        persist()
    }

    func addDrink(to playerID: UUID, count: Int = 1) {
        if let i = players.firstIndex(where: { $0.id == playerID }) { players[i].drinks += count }
    }

    private func finishTurn() {
        if !deck.isEmpty { deck.removeFirst() }
        currentIndex = (currentIndex + 1) % players.count
        randomTarget = nil
        turn += 1
        persist()
    }

    /// Called once when the awards screen appears.
    func markGameCompleted() {
        gamesCompleted += 1
        UserDefaults.standard.set(gamesCompleted, forKey: "gamesCompleted")
    }

    func endGame() {
        inGame = false
        deck = []
        UserDefaults.standard.removeObject(forKey: "savedGame")
    }

    // MARK: - Persistence
    private struct Saved: Codable { var players: [Player]; var settings: GameSettings; var deck: [Card]; var currentIndex: Int; var turn: Int; var totalCards: Int; var played: [Card] }

    func persist() {
        guard inGame else { return }
        let s = Saved(players: players, settings: settings, deck: deck, currentIndex: currentIndex, turn: turn, totalCards: totalCards, played: played)
        if let data = try? JSONEncoder().encode(s) { UserDefaults.standard.set(data, forKey: "savedGame") }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: "savedGame"),
              let s = try? JSONDecoder().decode(Saved.self, from: data), !s.deck.isEmpty else { return }
        players = s.players; settings = s.settings; deck = s.deck; currentIndex = s.currentIndex; turn = s.turn; totalCards = s.totalCards; played = s.played
        inGame = true
    }
}
