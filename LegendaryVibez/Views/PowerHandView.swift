import SwiftUI

struct PowerHandView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LVColor.bg.ignoresSafeArea()
                VStack(spacing: 14) {
                    ForEach(store.currentPlayer.hand) { card in
                        VStack(spacing: 12) {
                            Text(card.text).font(.body).foregroundStyle(.white).multilineTextAlignment(.center)
                            Button("Play This Card") {
                                store.playFromHand(card: card); Haptics.success(); dismiss()
                            }.buttonStyle(LVButtonStyle(color: LVColor.gold))
                        }
                        .padding(18).background(CardFrame(color: LVColor.gold))
                    }
                    Spacer()
                }.padding(20)
            }
            .navigationTitle("\(store.currentPlayer.name)'s Hand").navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
