import Domain
import StartFeature
import SwiftUI

@main
struct WishSpeakerApp: App {
    @State private var createFlowPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $createFlowPath) {
                StartView()
            }
            .environment(\.createFlowPath, $createFlowPath)
            .preferredColorScheme(.light)
        }
    }
}
