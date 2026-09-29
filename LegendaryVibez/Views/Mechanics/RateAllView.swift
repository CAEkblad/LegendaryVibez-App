import SwiftUI

/// "Rate everyone playing" as a swipeable roster with 1–10 sliders. Nothing is saved; it's for the room.
struct RateAllView: View {
    let players: [Player]
    @Environment(\.dismiss) private var dismiss
    @State private var ratings: [UUID: Double] = [:]

    var body: some View {
        NavigationStack {
            ZStack {
                LVColor.bg.ignoresSafeArea()
                TabView {
                    ForEach(players) { p in
                        VStack(spacing: 24) {
                            Spacer()
                            Text(p.emoji).font(.system(size: 80))
                            Text(p.name).font(.system(size: 34, weight: .black)).foregroundStyle(.white)
                            Text("\(Int(ratings[p.id] ?? 5))").font(.system(size: 72, weight: .black)).foregroundStyle(LVColor.red)
                                .contentTransition(.numericText())
                            Slider(value: Binding(get: { ratings[p.id] ?? 5 }, set: { ratings[p.id] = $0.rounded(); Haptics.tap() }), in: 1...10, step: 1)
                                .tint(LVColor.red).padding(.horizontal, 30)
                            Spacer()
                            Text("Swipe for the next player").font(.footnote).foregroundStyle(LVColor.grey)
                        }.padding(.bottom, 40)
                    }
                }
                .tabViewStyle(.page)
            }
            .navigationTitle("Rate Everyone").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}
