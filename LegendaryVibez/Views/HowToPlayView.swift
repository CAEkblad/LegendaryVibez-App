import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                LVColor.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        block("LEGENDARY RULES", [
                            "Complete the card or take the drink.",
                            "No complaining. Legendary vibes only.",
                            "Everyone must freely agree to participate in any challenge.",
                            "Players may always choose the drinking alternative instead."])
                        block("HOW TO PLAY", [
                            "Sit in a circle. Add players in seating order.",
                            "Everyone has their drink ready.",
                            "The person who partied most recently goes first.",
                            "Pass the phone clockwise. On your turn, draw, read it aloud, and follow the card.",
                            "Complete the card or take the listed drink."])
                        block("CARD TYPES", [
                            "Truth: Answer honestly or drink.",
                            "Dawgy Dare: Complete the dare or drink.",
                            "Act It Out: Perform the scene or drink.",
                            "Drink: Follow the drinking instruction.",
                            "Power: Control what happens next."])
                        Text("The game ends when the deck runs out or the group decides the vibes are legendary enough.")
                            .font(.footnote.italic()).foregroundStyle(LVColor.grey)
                    }.padding(22)
                }
            }
            .navigationTitle("How to Play").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
    private func block(_ title: String, _ lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.bold()).foregroundStyle(LVColor.gold).tracking(2)
            ForEach(lines, id: \.self) { l in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(LVColor.red).frame(width: 5, height: 5).padding(.top, 7)
                    Text(l).foregroundStyle(.white)
                }
            }
        }
    }
}
