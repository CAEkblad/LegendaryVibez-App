import Foundation

/// Builds a playable deck: filters by heat and packs, then shuffles with escalation weighting
/// so the night ramps up instead of opening on the hottest card.
enum DeckBuilder {
    static func build(settings: GameSettings, packs: [Pack]) -> [Card] {
        var pool = packs
            .filter { settings.enabledPacks.contains($0.pack_id) }
            .flatMap { $0.cards }
            .filter { $0.heat <= settings.heat.rawValue }

        // Never open with the Legendary tier; hold it back until the group is warm.
        pool.shuffle()

        let warmup = pool.filter { $0.type == .truth || $0.type == .drink || $0.type == .vote }
        let middle = pool.filter { $0.type == .dare || $0.type == .act }
        let power  = pool.filter { $0.type == .power }

        var deck: [Card] = []
        // First third: mostly warm-up cards, a few dares sprinkled in.
        let firstThird = max(pool.count / 3, 1)
        var w = warmup, m = middle
        for _ in 0..<firstThird {
            if !w.isEmpty && (m.isEmpty || Int.random(in: 0..<10) < 7) {
                deck.append(w.removeLast())
            } else if !m.isEmpty {
                deck.append(m.removeLast())
            }
        }
        // Rest: interleave what's left, then scatter Power cards across the back two-thirds.
        var rest = w + m
        rest.shuffle()
        deck.append(contentsOf: rest)
        for p in power {
            let lo = deck.count / 3
            let idx = deck.isEmpty ? 0 : Int.random(in: lo...deck.count)
            deck.insert(p, at: idx)
        }
        // Push heat-3 cards out of the opening ten.
        if deck.count > 12 {
            for i in 0..<10 where deck[i].heat == 3 {
                let j = Int.random(in: 10..<deck.count)
                deck.swapAt(i, j)
            }
        }
        if settings.deckSize == .quick { deck = Array(deck.prefix(30)) }
        return deck
    }
}
