import SwiftUI
import AVFoundation

class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 30.0

    private var player: AVPlayer?
    private var timeObserver: Any?

    init() {
        setupPlayer()
    }

    private func setupPlayer() {
        // In a real app, this would load the actual audio file
        // For the prototype, we use a mock implementation
        if let url = Bundle.main.url(forResource: "example_audio", withExtension: "mp4") {
            player = AVPlayer(url: url)
            setupTimeObserver()
        } else {
            // Mock duration for prototype
            duration = 30.0
        }
    }

    private func setupTimeObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }

        if let duration = player.currentItem?.asset.duration {
            self.duration = CMTimeGetSeconds(duration)
        }
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        if player != nil {
            player?.play()
        }
        isPlaying = true

        // Mock playback for prototype without actual audio file
        if player == nil {
            simulatePlayback()
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    private func simulatePlayback() {
        // Simulate playback progress for prototype
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if !self.isPlaying {
                timer.invalidate()
                return
            }

            self.currentTime += 0.5
            if self.currentTime >= self.duration {
                self.currentTime = 0
                self.isPlaying = false
                timer.invalidate()
            }
        }
    }

    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
}

struct AudioPlayerView: View {
    @StateObject private var viewModel = AudioPlayerViewModel()

    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            ProgressView(value: viewModel.currentTime, total: viewModel.duration)

            HStack {
                Text(formatTime(viewModel.currentTime))
                    .font(.caption)
                Spacer()
                Text(formatTime(viewModel.duration))
                    .font(.caption)
            }

            // Play/Pause button
            Button(action: {
                viewModel.togglePlayPause()
            }) {
                HStack {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    Text(viewModel.isPlaying ? "Pause" : "Play")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    AudioPlayerView()
        .padding()
}
