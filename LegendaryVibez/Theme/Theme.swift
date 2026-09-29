import SwiftUI

/// Brand palette pulled from the physical deck: black field, red frame, gold power cards.
enum LVColor {
    static let bg     = Color(red: 0.067, green: 0.067, blue: 0.067)   // #111111
    static let panel  = Color(red: 0.110, green: 0.110, blue: 0.110)   // #1C1C1C
    static let red    = Color(red: 0.847, green: 0.137, blue: 0.165)   // #D8232A
    static let gold   = Color(red: 0.851, green: 0.643, blue: 0.255)   // #D9A441
    static let grey   = Color(red: 0.722, green: 0.722, blue: 0.722)   // #B8B8B8
    static let line   = Color(red: 0.227, green: 0.227, blue: 0.227)   // #3A3A3A
}

extension CardType {
    var accent: Color { self == .power ? LVColor.gold : LVColor.red }
    var label: String {
        switch self {
        case .truth: return "TRUTH"
        case .dare:  return "DAWGY DARE"
        case .act:   return "ACT IT OUT"
        case .drink: return "DRINK"
        case .power: return "POWER"
        case .vote:  return "VOTE"
        }
    }
    var symbol: String {
        switch self {
        case .truth: return "mic.fill"
        case .dare:  return "flame.fill"
        case .act:   return "theatermasks.fill"
        case .drink: return "wineglass.fill"
        case .power: return "crown.fill"
        case .vote:  return "hand.point.up.left.fill"
        }
    }
}

struct LVButtonStyle: ButtonStyle {
    var color: Color = LVColor.red
    var filled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(filled ? color : Color.clear)
            .foregroundStyle(filled ? Color.white : color)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Ornamental frame mimicking the deck's corner brackets.
struct CardFrame: View {
    var color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22).fill(LVColor.panel)
            RoundedRectangle(cornerRadius: 22).stroke(color, lineWidth: 2.5)
            RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.35), lineWidth: 1).padding(8)
        }
    }
}
