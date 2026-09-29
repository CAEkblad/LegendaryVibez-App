import Foundation

enum Heat: Int, Codable, CaseIterable, Identifiable {
    case chill = 1, spicy = 2, legendary = 3
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .chill: return "Chill"
        case .spicy: return "Spicy"
        case .legendary: return "Legendary"
        }
    }
    var blurb: String {
        switch self {
        case .chill: return "Truths, drinks, mild dares. Safe for a mixed group."
        case .spicy: return "The full party. Dares get physical."
        case .legendary: return "Everything. No complaining, legendary vibes only."
        }
    }
}

enum DrinkMode: String, Codable, CaseIterable, Identifiable {
    case sips, shots, noAlcohol
    var id: String { rawValue }
    var title: String {
        switch self {
        case .sips: return "Sips"
        case .shots: return "Shots"
        case .noAlcohol: return "No Alcohol"
        }
    }
    /// Resolves the {shot} token in card text. Review-safe framing by default.
    var singular: String {
        switch self {
        case .sips: return "sip"
        case .shots: return "shot"
        case .noAlcohol: return "penalty point"
        }
    }
    var plural: String {
        switch self {
        case .sips: return "sips"
        case .shots: return "shots"
        case .noAlcohol: return "penalty points"
        }
    }
    var verb: String { self == .noAlcohol ? "Take the Penalty" : "Drink Instead" }
}

enum DeckSize: String, Codable, CaseIterable, Identifiable {
    case quick, full
    var id: String { rawValue }
    var title: String { self == .quick ? "Quick (30 cards)" : "Full Deck" }
}

struct GameSettings: Codable {
    var heat: Heat = .chill
    var drinkMode: DrinkMode = .sips
    var deckSize: DeckSize = .quick
    var enabledPacks: [String] = ["base"]
}
