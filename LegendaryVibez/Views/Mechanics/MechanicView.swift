import SwiftUI

/// Renders the interactive helper for a card, if it has one.
struct MechanicView: View {
    let card: Card
    @Binding var done: Bool

    var body: some View {
        switch card.mechanic {
        case .timer, .phone_timer:
            CountdownView(seconds: card.mechanic_value ?? 30, done: $done)
        case .freeze:
            FreezeView(done: $done)
        case .spin:
            SpinBottleView()
        case .rps:
            RPSView()
        case .vote:
            VoteView(done: $done)
        default:
            EmptyView()
        }
    }
}

struct CountdownView: View {
    let seconds: Int
    @Binding var done: Bool
    @State private var remaining: Int
    @State private var running = false
    @State private var timer: Timer?

    init(seconds: Int, done: Binding<Bool>) {
        self.seconds = seconds; _done = done; _remaining = State(initialValue: seconds)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(LVColor.line, lineWidth: 6)
                Circle().trim(from: 0, to: CGFloat(remaining) / CGFloat(max(seconds, 1)))
                    .stroke(LVColor.red, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90)).animation(.linear(duration: 1), value: remaining)
                Text(label).font(.headline.monospacedDigit()).foregroundStyle(.white)
            }.frame(width: 64, height: 64)
            Button(running ? "Pause" : (remaining == seconds ? "Start Timer" : "Resume")) { toggle() }
                .buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
        }
        .onDisappear { timer?.invalidate() }
    }

    private var label: String { remaining >= 60 ? String(format: "%d:%02d", remaining / 60, remaining % 60) : "\(remaining)" }

    private func toggle() {
        if running { timer?.invalidate(); running = false; return }
        running = true; Haptics.tap()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if remaining > 0 { remaining -= 1 }
            if remaining <= 3 && remaining > 0 { Sound.shared.play(.tick) }
            if remaining == 0 { t.invalidate(); running = false; done = true; Haptics.warning(); Sound.shared.play(.buzzer) }
        }
    }
}

/// "Everybody freeze": random 5–20s delay, then a loud buzz. First to move drinks.
struct FreezeView: View {
    @Binding var done: Bool
    @State private var armed = false
    @State private var fired = false

    var body: some View {
        Button(fired ? "MOVE! First one to flinch drinks" : (armed ? "FREEZE..." : "Arm the Freeze")) {
            guard !armed else { return }
            armed = true; Haptics.tap()
            let delay = Double.random(in: 5...20)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                fired = true; done = true
                Sound.shared.play(.buzzer); Haptics.warning(); Haptics.warning(); Haptics.warning()
            }
        }
        .buttonStyle(LVButtonStyle(color: fired ? LVColor.red : LVColor.gold, filled: fired))
    }
}

struct SpinBottleView: View {
    @EnvironmentObject var store: GameStore
    @State private var angle: Double = 0
    @State private var landed: Player?

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ForEach(Array(store.players.enumerated()), id: \.element.id) { i, p in
                    let a = Double(i) / Double(store.players.count) * 2 * .pi - .pi / 2
                    Text(p.emoji).font(.title3)
                        .offset(x: cos(a) * 70, y: sin(a) * 70)
                }
                Image(systemName: "arrow.up").font(.system(size: 44, weight: .black))
                    .foregroundStyle(LVColor.gold).rotationEffect(.degrees(angle))
            }.frame(height: 170)
            if let l = landed {
                Text("It's \(l.name)!").font(.headline).foregroundStyle(.white)
            } else {
                Button("Spin") {
                    let n = store.players.count
                    let target = Int.random(in: 0..<n)
                    let per = 360.0 / Double(n)
                    let turns = Double(Int.random(in: 3...6)) * 360
                    withAnimation(.timingCurve(0.2, 0.8, 0.3, 1, duration: 2.6)) { angle += turns + Double(target) * per - (angle.truncatingRemainder(dividingBy: 360)) }
                    Haptics.draw(); Sound.shared.play(.flip)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { landed = store.players[target]; Haptics.success(); Sound.shared.play(.ding) }
                }.buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
            }
        }
    }
}

struct RPSView: View {
    @State private var a: Int?
    @State private var b: Int?
    private let opts = ["✊","✋","✌️"]

    var body: some View {
        VStack(spacing: 8) {
            Text(result).font(.subheadline.bold()).foregroundStyle(.white)
            HStack(spacing: 20) {
                picker("You", $a); picker("Them", $b)
            }
        }
    }
    private func picker(_ label: String, _ sel: Binding<Int?>) -> some View {
        VStack(spacing: 6) {
            Text(label).font(.caption).foregroundStyle(LVColor.grey)
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Button(opts[i]) { sel.wrappedValue = i; Haptics.tap() }
                        .font(.title2).padding(8)
                        .background(sel.wrappedValue == i ? LVColor.gold.opacity(0.3) : LVColor.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
    private var result: String {
        guard let a, let b else { return "Both pick, then reveal" }
        if a == b { return "Tie. Go again." }
        return (a - b + 3) % 3 == 1 ? "You win. They drink." : "You lose. Drink up."
    }
}
