import SwiftUI
import Domain
import Feature

@main
struct WishSpeakerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartView()
            }
			.preferredColorScheme(.light)
            .environmentObject(appState)
        }
    }
}
