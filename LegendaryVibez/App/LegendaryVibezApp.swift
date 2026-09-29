import SwiftUI

@main
struct LegendaryVibezApp: App {
    @StateObject private var store = GameStore()
    @StateObject private var storeKit = StoreManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(storeKit)
                .preferredColorScheme(.dark)
        }
    }
}

/// Root switches between the age gate and the main app.
struct RootView: View {
    @EnvironmentObject var store: GameStore
    @AppStorage("ageConfirmed") private var ageConfirmed = false

    var body: some View {
        if ageConfirmed {
            HomeView()
        } else {
            AgeGateView { ageConfirmed = true }
        }
    }
}
