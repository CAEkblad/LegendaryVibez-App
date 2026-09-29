import Foundation

enum CardType: String, Codable, CaseIterable {
    case truth, dare, act, drink, power, vote
}

enum Mechanic: String, Codable {
    case none, timer, spin, rps, freeze, phone_timer, rate_all, skip, vote
}

enum Target: String, Codable {
    case none, left, right, random, chosen, all
}

struct Card: Codable, Identifiable, Hashable {
    let id: String
    let type: CardType
    let text: String
    let heat: Int                 // 1 chill, 2 spicy, 3 legendary
    let targets: [Target]
    let mechanic: Mechanic
    let mechanic_value: Int?
    let drink_alt: Int
    let gender_filter: String?

    var needsChosenPlayer: Bool { targets.contains(.chosen) }
}

struct Pack: Codable {
    let pack_id: String
    let pack_name: String
    let version: Int
    let cards: [Card]
}
