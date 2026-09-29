import SwiftUI

/// 3-2-1 countdown, everybody points, then tap who got the most fingers. They drink.
struct VoteView: View {
    @EnvironmentObject var store: GameStore
    @Binding var done: Bool
    @State private var count: Int? = nil
    @State private var winner: Player?

    var body: some View {
        VStack(spacing: 10) {
            if let w = winner {
                Text("\(w.emoji) \(w.name) drinks").font(.headline).foregroundStyle(.white)
            } else if let c = count {
                Text(c > 0 ? "\(c)" : "POINT!")
                    .font(.system(size: c > 0 ? 56 : 40, weight: .black)).foregroundStyle(LVColor.red)
                    .contentTransition(.numericText())
                if c == 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.players) { p in
                                Button {
                                    winner = p; done = true; store.addDrink(to: p.id); Haptics.success(); Sound.shared.play(.drink)
                                } label: {
                                    VStack(spacing: 2) { Text(p.emoji).font(.title2); Text(p.name).font(.caption).lineLimit(1) }
                                        .foregroundStyle(.white).padding(10).frame(minWidth: 70)
                                        .background(LVColor.panel).clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    Text("Tap who got the most votes").font(.caption).foregroundStyle(LVColor.grey)
                }
            } else {
                Button("Count Us Down") { start() }.buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
            }
        }
    }

    private func start() {
        count = 3; Sound.shared.play(.tick); Haptics.tap()
        for i in 1...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                withAnimation { count = 3 - i }
                if 3 - i > 0 { Sound.shared.play(.tick); Haptics.tap() } else { Sound.shared.play(.buzzer); Haptics.warning() }
            }
        }
    }
}
