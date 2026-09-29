import AVFoundation

/// Tiny SFX player. Files live in Resources/Sounds; placeholders are synthesized, swap for real design later.
final class Sound {
    static let shared = Sound()
    enum FX: String { case flip, tap, ding, buzzer, tick, drink, fanfare }

    private var players: [FX: AVAudioPlayer] = [:]
    var enabled: Bool {
        get { UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "soundEnabled") }
    }

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        for fx in [FX.flip, .tap, .ding, .buzzer, .tick, .drink, .fanfare] {
            if let url = Bundle.main.url(forResource: fx.rawValue, withExtension: "wav"),
               let p = try? AVAudioPlayer(contentsOf: url) {
                p.prepareToPlay(); players[fx] = p
            }
        }
    }

    func play(_ fx: FX) {
        guard enabled, let p = players[fx] else { return }
        p.currentTime = 0; p.play()
    }
}
