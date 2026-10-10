import AVFoundation
import Domain
import StartFeature
import SwiftUI

@main
struct WishSpeakerApp: App {
    @State private var createFlowPath = NavigationPath()

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

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
