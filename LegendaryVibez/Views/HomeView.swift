import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: GameStore
    @State private var showSetup = false
    @State private var showHowTo = false
    @State private var resumeGame = false
    @State private var showStore = false
    @State private var soundOn = Sound.shared.enabled
    @EnvironmentObject var storeKit: StoreManager

    var body: some View {
        NavigationStack {
            ZStack {
                LVColor.bg.ignoresSafeArea()
                VStack(spacing: 18) {
                    Spacer()
                    LogoView()
                    Text("iOS PARTY GAME").font(.caption.bold()).foregroundStyle(LVColor.gold).tracking(3)
                    Spacer()
                    if store.inGame {
                        Button("Resume Game") { resumeGame = true }
                            .buttonStyle(LVButtonStyle())
                        Button("End Current Game") { store.endGame() }
                            .buttonStyle(LVButtonStyle(color: LVColor.grey, filled: false))
                    } else {
                        Button("Play") { showSetup = true }.buttonStyle(LVButtonStyle())
                    }
                    Button("How to Play") { showHowTo = true }.buttonStyle(LVButtonStyle(color: LVColor.gold, filled: false))
                    if !storeKit.fullDeckUnlocked {
                        Button("Unlock Full Deck · \(storeKit.priceLabel)") { showStore = true }
                            .font(.footnote.bold()).foregroundStyle(LVColor.gold)
                    }
                    Button { soundOn.toggle(); Sound.shared.enabled = soundOn; if soundOn { Sound.shared.play(.tap) } } label: {
                        Image(systemName: soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill").foregroundStyle(LVColor.grey)
                    }.padding(.top, 4)
                    Text("Drink responsibly.").font(.footnote).foregroundStyle(LVColor.grey).padding(.top, 8)
                }
                .padding(.horizontal, 28).padding(.bottom, 24)
            }
            .navigationDestination(isPresented: $showSetup) { PlayerSetupView() }
            .navigationDestination(isPresented: $resumeGame) { GameView() }
            .sheet(isPresented: $showHowTo) { HowToPlayView() }
            .sheet(isPresented: $showStore) { StoreView() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
