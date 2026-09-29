import Foundation

struct Player: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var emoji: String = "🔥"

    // Per-game tallies
    var drinks: Int = 0
    var completed: Int = 0
    var chickenedOut: Int = 0
    var legendaryCompleted: Int = 0
    var powerCardsPlayed: Int = 0
    var hand: [Card] = []          // held Power cards
}
