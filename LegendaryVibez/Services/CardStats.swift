import Foundation

/// Per-card play stats kept on device. This is the data that decides what goes in After Dark.
struct CardStat: Codable { var shown = 0; var done = 0; var skipped = 0; var best = 0 }

final class CardStats {
    static let shared = CardStats()
    private let key = "cardStats"
    private(set) var stats: [String: CardStat]

    private init() {
        if let d = UserDefaults.standard.data(forKey: key), let s = try? JSONDecoder().decode([String: CardStat].self, from: d) {
            stats = s
        } else { stats = [:] }
    }

    func record(_ card: Card, done: Bool) {
        var s = stats[card.id] ?? CardStat()
        s.shown += 1; if done { s.done += 1 } else { s.skipped += 1 }
        stats[card.id] = s; save()
    }
    func best(_ card: Card) { var s = stats[card.id] ?? CardStat(); s.best += 1; stats[card.id] = s; save() }
    private func save() { if let d = try? JSONEncoder().encode(stats) { UserDefaults.standard.set(d, forKey: key) } }

    /// Export for the dev: card id, shown, done, skipped, best. Read via Xcode > Devices > container, or a debug share button.
    func csv() -> String {
        "id,shown,done,skipped,best\n" + stats.map { "\($0.key),\($0.value.shown),\($0.value.done),\($0.value.skipped),\($0.value.best)" }.joined(separator: "\n")
    }
}
