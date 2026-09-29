import Foundation

enum DeckLoader {
    /// Loads a pack JSON from the app bundle. Packs are named "<pack_id>_deck.json".
    static func load(packID: String) -> Pack? {
        guard let url = Bundle.main.url(forResource: "\(packID)_deck", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            assertionFailure("Missing pack \(packID)_deck.json in bundle")
            return nil
        }
        do {
            return try JSONDecoder().decode(Pack.self, from: data)
        } catch {
            assertionFailure("Pack \(packID) failed to decode: \(error)")
            return nil
        }
    }
}
