import SwiftUI
import Feature

@main
struct WishSpeakerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartView()
            }
            .preferredColorScheme(.light)
        }
    }
}
