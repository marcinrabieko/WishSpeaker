import AVFoundation
import Domain
import StartFeature
import SwiftUI

@main
struct WishSpeakerApp: App {
    @State private var createFlowPath = NavigationPath()

    init() {
        // setActive(_:) blocks until the audio route is ready, which can stall the UI
        // (e.g. delaying the keyboard) when called on the main thread — so the whole
        // session setup runs off it. The async activate(options:) API would avoid this
        // too, but it's iOS 27+ only.
        Task.detached(priority: .userInitiated) {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default)
            try? session.setActive(true)
        }
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
