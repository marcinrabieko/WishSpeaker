import AVFoundation
import Observation

/// Drives a single `AVPlayer` for a URL, coordinating with `VoicePlaybackCoordinator`
/// so only one instance plays at a time across the app (Library rows, Example Wishes,
/// Voice Selection previews, WishDetail). Reads duration straight from the player
/// instead of trusting a caller-supplied value, so it works equally well for a known
/// local recording (VoiceAsset.duration) or an unknown-length remote preview.
@MainActor
@Observable
public final class PlaybackState {
    public var isPlaying = false
    public var progress: Double = 0
    public var duration: TimeInterval = 0
    public var isLoading = false

    private var id: UUID?
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?

    public init() {}

    public func attach(id: UUID, url: URL?) {
        self.id = id

        guard let url else {
            return
        }

        isLoading = true
        player = AVPlayer(url: url)

        VoicePlaybackCoordinator.shared.register(id: id) { [weak self] in
            self?.pause()
        }

        statusObservation = player?.currentItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self else { return }

                switch item.status {
                case .readyToPlay:
                    self.isLoading = false
                    if let seconds = item.duration.seconds as Double?, seconds.isFinite, seconds > 0 {
                        self.duration = seconds
                    }

                case .failed:
                    self.isLoading = false

                default:
                    break
                }
            }
        }

        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self, duration > 0 else {
                return
            }

            progress = time.seconds / duration
        }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isPlaying = false
                self?.progress = 0
                self?.player?.seek(to: .zero)
            }
        }
    }

    public func detach() {
        pause()

        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }

        statusObservation = nil

        if let id {
            VoicePlaybackCoordinator.shared.unregister(id: id)
        }

        player = nil
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    public func seek(to progress: Double) {
        guard duration > 0 else { return }
        self.progress = progress
        player?.seek(to: CMTime(seconds: progress * duration, preferredTimescale: 600))
    }

    private func play() {
        guard let id else { return }
        VoicePlaybackCoordinator.shared.willStartPlaying(id: id)
        player?.play()
        isPlaying = true
    }

    private func pause() {
        player?.pause()
        isPlaying = false

        if let id {
            VoicePlaybackCoordinator.shared.didStopPlaying(id: id)
        }
    }
}
