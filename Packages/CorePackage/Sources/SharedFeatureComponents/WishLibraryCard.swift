import DesignSystem
import Domain
import Localizations
import SwiftUI

/// Adapts its presentation to whichever assets the Wish currently has, using the
/// priority Video > Voice > Text — a Wish can evolve from text-only to text+voice to
/// text+voice+video without ever becoming a different Library row.
public struct WishLibraryCard: View {
    let wish: Wish

    public init(wish: Wish) {
        self.wish = wish
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            identity

            if wish.videoAsset != nil {
                VideoCardBody(wish: wish)
            } else if wish.voiceAsset != nil {
                VoiceCardBody(wish: wish)
            } else {
                TextCardBody(wish: wish)
            }
        }
        .padding(WSSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(Color.wsSoftBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xxs) {
            Text(L10n.libraryCardTitle(wish.occasionTitle, wish.recipient))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.wsPrimaryText)

            HStack(spacing: WSSpacing.xs) {
                Text(wish.variant.displayName)
                Text("•")
                Text(wish.createdAt.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.system(size: 13))
            .foregroundColor(.wsSecondaryText)
        }
    }
}

private struct TextCardBody: View {
    let wish: Wish

    var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            Text(wish.text)
                .font(.system(size: 15))
                .foregroundColor(.wsSecondaryText)
                .lineSpacing(3)
                .lineLimit(3)

            HStack(spacing: 4) {
                Text(L10n.libraryPlayButton)
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.wsPrimary)
        }
    }
}

private struct VoiceCardBody: View {
    let wish: Wish

    var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            if let voiceAsset = wish.voiceAsset {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.system(size: 12))
                    Text(voiceAsset.voiceDisplayName)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.wsPrimary)

                LibraryVoicePlayer(voiceAsset: voiceAsset)
            }
        }
    }
}

private struct VideoCardBody: View {
    let wish: Wish

    var body: some View {
        if let videoAsset = wish.videoAsset {
            LibraryVideoThumbnail(videoAsset: videoAsset)
        }
    }
}

/// Compact, list-friendly playback UI. Presentation only — no AVPlayer instance is
/// created here, so a scrolling Library list never runs multiple active players.
private struct LibraryVoicePlayer: View {
    let voiceAsset: VoiceAsset

    @State private var isPlaying = false
    @State private var progress: Double = 0

    var body: some View {
        HStack(spacing: WSSpacing.xs) {
            Button {
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.wsPrimary)
            }
            .buttonStyle(.plain)

            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.wsSoftBorder)
                            .frame(height: 3)

                        Capsule()
                            .fill(Color.wsPrimary)
                            .frame(width: geometry.size.width * progress, height: 3)
                    }
                }
                .frame(height: 3)

                HStack {
                    Text(formattedTime(progress * voiceAsset.duration))
                        .monospacedDigit()

                    Spacer()

                    Text(formattedTime(voiceAsset.duration))
                        .monospacedDigit()
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.wsSecondaryText)
            }
        }
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Static thumbnail + play affordance only — intentionally not backed by a video
/// player, so a scrolling Library list never has to manage embedded playback.
private struct LibraryVideoThumbnail: View {
    let videoAsset: VideoAsset

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: WSRadius.button, style: .continuous)
                .fill(Color.wsSecondaryBackground)
                .frame(height: 160)

            Image(systemName: "play.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(.wsPrimary)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Text(formattedTime(videoAsset.duration))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, WSSpacing.xs)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Capsule())
                        .padding(WSSpacing.xs)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.button, style: .continuous))
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
