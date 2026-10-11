import AVFoundation
import Domain
import StartFeature
import SwiftUI
#if DEBUG
import VideoPrototypeFeature
#endif

@main
struct WishSpeakerApp: App {
    @State private var createFlowPath = NavigationPath()

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            // Swaps the entire root view to the native video-renderer prototype's
            // diagnostic screen in Debug builds only — see VideoPrototypeFeature's
            // PrototypeRenderer.swift for why this exists. Never reaches Release
            // builds, never touches the real StartView-rooted navigation flow.
            NavigationStack {
                VideoPrototypeView()
            }
            #else
            NavigationStack(path: $createFlowPath) {
                StartView()
            }
            .environment(\.createFlowPath, $createFlowPath)
            .preferredColorScheme(.light)
            #endif
        }
    }
}
