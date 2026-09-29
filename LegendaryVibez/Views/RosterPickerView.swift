import SwiftUI

struct RosterPickerView: View {
    let players: [Player]
    var onPick: (Player) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LVColor.bg.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(players) { p in
                            Button { onPick(p) } label: {
                                VStack(spacing: 6) {
                                    Text(p.emoji).font(.system(size: 40))
                                    Text(p.name).font(.headline).foregroundStyle(.white).lineLimit(1).minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 20)
                                .background(LVColor.panel).clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }.padding(20)
                }
            }
            .navigationTitle("Choose a Player").navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}
