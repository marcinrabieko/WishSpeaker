import AVFoundation
import SwiftUI

@MainActor
@Observable
public final class AudioPlayerViewModel {
    public var isPlaying: Bool = false
    public var currentTime: TimeInterval = 0
    public var duration: TimeInterval = 30.0

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var simulationTask: Task<Void, Never>?

    public init() {
        setupPlayer()
    }

    private func setupPlayer() {
        if let url = Bundle.main.url(forResource: "example_audio", withExtension: "mp4") {
            player = AVPlayer(url: url)
            setupTimeObserver()
        } else {
            duration = 30.0
        }
    }

    private func setupTimeObserver() {
        guard let player
        else {
            return
        }

        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
            }
        }

        if let duration = player.currentItem?.asset.duration {
            self.duration = CMTimeGetSeconds(duration)
        }
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    public func play() {
        if player != nil {
            player?.play()
        }
        isPlaying = true

        if player == nil {
            simulatePlayback()
        }
    }

    public func pause() {
        player?.pause()
        isPlaying = false
        simulationTask?.cancel()
    }

    public func seek(to progress: Double) {
        let targetTime = progress * duration
        currentTime = targetTime
        if let player {
            player.seek(to: CMTime(seconds: targetTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
    }

    private func simulatePlayback() {
        simulationTask?.cancel()
        simulationTask = Task { [weak self] in
            while let strongSelf = self, strongSelf.isPlaying {
                try? await Task.sleep(for: .seconds(0.1))
                guard let strongSelf = self, strongSelf.isPlaying else {
                    return
                }

                strongSelf.currentTime += 0.1
                if strongSelf.currentTime >= strongSelf.duration {
                    strongSelf.currentTime = 0
                    strongSelf.isPlaying = false
                }
            }
        }
    }
}

public struct AudioPlayerView: View {
    @State private var viewModel = AudioPlayerViewModel()

    public init() {}

    public var body: some View {
        HStack(spacing: WSSpacing.sm) {
            // Play/Pause button - larger and gradient
            Button {
                viewModel.togglePlayPause()
            } label: {
                ZStack {
                    Circle()
                        .fill(WSGradient.accent)
                        .frame(width: WSSize.playButtonSize, height: WSSize.playButtonSize)
                        .shadow(color: Color.wsAccent.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .offset(x: viewModel.isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(PlayButtonStyle())

            VStack(spacing: WSSpacing.xs) {
                // Progress bar with gradient
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 4)

                        // Progress with gradient
                        Capsule()
                            .fill(WSGradient.accent)
                            .frame(width: max(0, geometry.size.width * (viewModel.currentTime / viewModel.duration)), height: 4)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let progress = min(max(0, value.location.x / geometry.size.width), 1)
                                viewModel.seek(to: progress)
                            }
                    )
                }
                .frame(height: 4)

                // Time labels
                HStack {
                    Text(formatTime(viewModel.currentTime))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.wsSecondaryText)
                        .monospacedDigit()

                    Spacer()

                    Text(formatTime(viewModel.duration))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.wsSecondaryText)
                        .monospacedDigit()
                }
            }
        }
        .padding(WSSpacing.sm)
        .padding(.vertical, WSSpacing.xs)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

public struct PlayButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        AudioPlayerView()
    }
    .padding(.horizontal, WSSpacing.horizontalPadding)
    .padding()
    .background(Color(.systemGray6))
}
