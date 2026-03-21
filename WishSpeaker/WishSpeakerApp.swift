import SwiftUI

@main
struct WishSpeakerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartView()
            }
            .environmentObject(appState)
        }
    }
}
