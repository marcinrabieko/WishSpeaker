import StartFeature
import SwiftUI

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
