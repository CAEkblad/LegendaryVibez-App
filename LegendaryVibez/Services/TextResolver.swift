import Foundation

/// Fills card placeholders with real player names and drink-mode wording.
struct TextResolver {
    let players: [Player]
    let currentIndex: Int
    let drinkMode: DrinkMode
    var chosen: Player?
    var random: Player?

    private var left: Player  { players[(currentIndex + 1) % players.count] }
    private var right: Player { players[(currentIndex - 1 + players.count) % players.count] }

    func resolve(_ text: String) -> String {
        var t = text
        t = t.replacingOccurrences(of: "{left}",  with: left.name)
        t = t.replacingOccurrences(of: "{right}", with: right.name)
        t = t.replacingOccurrences(of: "{random}", with: random?.name ?? left.name)
        t = t.replacingOccurrences(of: "{chosen}", with: chosen?.name ?? "a player you choose")
        t = t.replacingOccurrences(of: "{shots}", with: drinkMode.plural)
        t = t.replacingOccurrences(of: "{shot}",  with: drinkMode.singular)
        return t
    }
}
