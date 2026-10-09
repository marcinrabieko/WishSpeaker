import DesignSystem
import Domain
import SwiftUI

/// Compact play/pause control for previewing a remote audio URL whose duration is
/// unknown ahead of time (e.g. an ElevenLabs voice sample) — reuses `PlaybackState`
/// and `VoicePlaybackCoordinator`, the same infrastructure as `InlineVoicePlayer`, so
/// starting a preview stops any other voice preview or Library/Example playback.
/// Hidden entirely when `previewURL` is nil — a missing preview never blocks Voice
/// selection itself.
///
/// Resolves `previewURL` through `VoicePreviewCache` before attaching playback — the
/// first tap downloads and caches the sample to disk, every later tap (this visit, or
/// after the app relaunches) plays the local file instead of re-fetching it from
/// ElevenLabs/Google Storage.
public struct VoicePreviewPlayer: View {
    let previewURL: URL?

    @State private var playback = PlaybackState()
    @State private var resolvedURL: URL?
    private let id = UUID()

    public init(previewURL: URL?) {
        self.previewURL = previewURL
    }

    public var body: some View {
        if previewURL != nil {
            Button {
                playback.togglePlayPause()
            } label: {
                ZStack {
                    if playback.isLoading {
                        ProgressView()
                            .tint(.wsPrimary)
                    } else {
                        Image(systemName: playback.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.wsPrimary)
                    }
                }
                .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .disabled(playback.isLoading)
            .task {
                guard let previewURL else { return }
                resolvedURL = await VoicePreviewCache.shared.localURL(for: previewURL)
                playback.attach(id: id, url: resolvedURL)
            }
            .onDisappear {
                playback.detach()
            }
        }
    }
}
