import DesignSystem
import Domain
import Localizations
import SwiftUI

/// Adapts its presentation to whichever assets the Wish currently has, using the
/// priority Video > Voice > Text — a Wish can evolve from text-only to text+voice to
/// text+voice+video without ever becoming a different Library row.
///
/// The card owns its own tap target instead of being wrapped in an external
/// `NavigationLink`, so an inline player's own Buttons can intercept taps (play/pause,
/// scrub) without also opening the Wish — nesting a Button inside a NavigationLink's
/// label does not reliably suppress the outer navigation gesture in SwiftUI.
public struct WishLibraryCard: View {
    let wish: Wish
    let onTap: () -> Void

    public init(wish: Wish, onTap: @escaping () -> Void) {
        self.wish = wish
        self.onTap = onTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            identity
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)

            if wish.videoAsset != nil {
                VideoCardBody(videoAsset: wish.videoAsset)
                    .onTapGesture(perform: onTap)
            } else if let voiceAsset = wish.voiceAsset {
                VoiceCardBody(voiceAsset: voiceAsset)
            } else {
                Text(wish.text)
                    .font(.system(size: 15))
                    .foregroundColor(.wsPrimaryText.opacity(0.75))
                    .lineSpacing(3)
                    .lineLimit(3)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTap)
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
            Text(wish.recipient)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.wsPrimaryText)

            Text(WishMetadataText.format(occasionKind: wish.occasionKind, variant: wish.variant, date: wish.createdAt))
                .font(.system(size: 13))
                .foregroundColor(.wsSecondaryText)
        }
    }
}

/// Shared "occasion · variant · date" formatting for Library cards and WishDetailView —
/// always built from a localized format string, never a manually concatenated sentence,
/// and always using the user's current locale for the date.
public enum WishMetadataText {
    public static func format(occasionKind: OccasionKind, variant: WishVariant, date: Date) -> String {
        L10n.libraryMetadataFormat(
            occasionKind.displayName,
            variant.displayName,
            date.formatted(date: .abbreviated, time: .omitted)
        )
    }
}

private struct VoiceCardBody: View {
    let voiceAsset: VoiceAsset

    var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: "waveform")
                    .font(.system(size: 12))
                Text(voiceAsset.voiceDisplayName)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.wsPrimary)

            InlineVoicePlayer(voiceAsset: voiceAsset)
        }
    }
}

private struct VideoCardBody: View {
    let videoAsset: VideoAsset?

    var body: some View {
        if let videoAsset {
            LibraryVideoThumbnail(videoAsset: videoAsset)
        }
    }
}

/// Compact, list-friendly playback UI. Presentation only — no AVPlayer instance is
/// created here, so a scrolling Library list never runs multiple active players.
/// Its Buttons/DragGesture are the only interactive surface inside the card that must
/// NOT trigger navigation — everything else in the card forwards taps to `onTap`.
public struct InlineVoicePlayer: View {
    let voiceAsset: VoiceAsset

    @State private var isPlaying = false
    @State private var progress: Double = 0

    public init(voiceAsset: VoiceAsset) {
        self.voiceAsset = voiceAsset
    }

    public var body: some View {
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
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                progress = min(max(0, value.location.x / geometry.size.width), 1)
                            }
                    )
                }
                .frame(height: 12)

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
public struct LibraryVideoThumbnail: View {
    let videoAsset: VideoAsset
    let height: CGFloat
    let playIconSize: CGFloat

    public init(videoAsset: VideoAsset, height: CGFloat = 160, playIconSize: CGFloat = 44) {
        self.videoAsset = videoAsset
        self.height = height
        self.playIconSize = playIconSize
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: WSRadius.button, style: .continuous)
                .fill(Color.wsSecondaryBackground)
                .frame(height: height)

            Image(systemName: "play.circle.fill")
                .font(.system(size: playIconSize))
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
