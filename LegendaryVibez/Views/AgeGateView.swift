import SwiftUI

struct AgeGateView: View {
    var onConfirm: () -> Void
    var body: some View {
        ZStack {
            LVColor.bg.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                LogoView()
                VStack(spacing: 10) {
                    Text("21+ ONLY").font(.system(size: 30, weight: .black)).foregroundStyle(.white)
                    Text("This game contains adult humor and references to alcohol. You must be of legal drinking age to play.")
                        .font(.body).foregroundStyle(LVColor.grey).multilineTextAlignment(.center)
                    Text("Drink responsibly. Everyone must freely agree to participate in any challenge. There's always a non-alcoholic mode.")
                        .font(.footnote).foregroundStyle(LVColor.grey.opacity(0.8)).multilineTextAlignment(.center)
                        .padding(.top, 6)
                }.padding(.horizontal, 28)
                Spacer()
                Button("I'm 21 or older") { Haptics.success(); onConfirm() }
                    .buttonStyle(LVButtonStyle())
                    .padding(.horizontal, 28).padding(.bottom, 24)
            }
        }
    }
}

struct LogoView: View {
    var body: some View {
        VStack(spacing: -6) {
            Text("LEGENDARY").font(.system(size: 34, weight: .black)).foregroundStyle(.white).tracking(2)
            Text("VIBEZ").font(.system(size: 44, weight: .black)).foregroundStyle(LVColor.red).tracking(3)
        }
    }
}
