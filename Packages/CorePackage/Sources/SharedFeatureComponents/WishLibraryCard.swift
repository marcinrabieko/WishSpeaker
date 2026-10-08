import AVFoundation
import DesignSystem
import Domain
import Localizations
import SwiftUI
import UIKit

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
    let showDate: Bool
    let onTap: () -> Void

    /// `showDate` is false for curated Example Wishes, which have no creation date —
    /// they aren't saved Library items, so showing one would be misleading.
    public init(wish: Wish, showDate: Bool = true, onTap: @escaping () -> Void) {
        self.wish = wish
        self.showDate = showDate
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

            Text(
                showDate
                    ? WishMetadataText.format(occasionKind: wish.occasionKind, variant: wish.variant, date: wish.createdAt)
                    : WishMetadataText.format(occasionKind: wish.occasionKind, variant: wish.variant)
            )
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

    /// No-date variant for curated Example Wishes, which aren't saved Library items.
    public static func format(occasionKind: OccasionKind, variant: WishVariant) -> String {
        L10n.exampleWishesMetadataFormat(occasionKind.displayName, variant.displayName)
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

            InlineVoicePlayer(voiceAsset: voiceAsset, audioURL: voiceAsset.audioURL)
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

/// Compact, list-friendly playback UI backed by a real `AVPlayer` when `audioURL`
/// resolves to an existing file, falling back to a disabled, non-interactive progress
/// display otherwise (e.g. bundled example audio not yet recorded for a language).
/// Coordinates with `VoicePlaybackCoordinator` so starting one instance stops any other
/// instance currently playing. Its Buttons/DragGesture are the only interactive surface
/// inside the card that must NOT trigger navigation — everything else in the card
/// forwards taps to `onTap`.
public struct InlineVoicePlayer: View {
    let voiceAsset: VoiceAsset
    let audioURL: URL?

    @State private var playback = PlaybackState()
    private let id = UUID()

    public init(voiceAsset: VoiceAsset, audioURL: URL? = nil) {
        self.voiceAsset = voiceAsset
        self.audioURL = audioURL
    }

    public var body: some View {
        HStack(spacing: WSSpacing.xs) {
            Button {
                didTapPlayPause()
            } label: {
                Image(systemName: playback.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(audioURL == nil ? .wsSecondaryText.opacity(0.5) : .wsPrimary)
            }
            .buttonStyle(.plain)
            .disabled(audioURL == nil)

            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.wsSoftBorder)
                            .frame(height: 3)

                        Capsule()
                            .fill(Color.wsPrimary)
                            .frame(width: geometry.size.width * playback.progress, height: 3)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard audioURL != nil else { return }
                                let progress = min(max(0, value.location.x / geometry.size.width), 1)
                                playback.seek(to: progress)
                            }
                    )
                }
                .frame(height: 12)

                HStack {
                    Text(formattedTime(playback.progress * displayDuration))
                        .monospacedDigit()

                    Spacer()

                    Text(formattedTime(displayDuration))
                        .monospacedDigit()
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.wsSecondaryText)
            }
        }
        .onAppear {
            playback.attach(id: id, url: audioURL)
        }
        .onDisappear {
            playback.detach()
        }
    }

    /// The player reports 0 until its AVPlayerItem becomes ready — fall back to the
    /// known VoiceAsset duration so the label isn't stuck at "0:00" while loading.
    private var displayDuration: TimeInterval {
        playback.duration > 0 ? playback.duration : voiceAsset.duration
    }

    private func didTapPlayPause() {
        guard audioURL != nil else { return }
        playback.togglePlayPause()
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Static thumbnail + play affordance only — intentionally not backed by a video
/// player, so a scrolling Library list never has to manage embedded playback.
///
/// The generated video is itself a 1:1 square (see WishSpeaker-Backend's
/// video_service.py) — the container matches that aspect ratio exactly (full card
/// width, equal height) rather than imposing an unrelated wide/short shape, so the
/// thumbnail fills it edge-to-edge with no cropping and no empty side bars.
public struct LibraryVideoThumbnail: View {
    let videoAsset: VideoAsset
    let playIconSize: CGFloat

    public init(videoAsset: VideoAsset, playIconSize: CGFloat = 44) {
        self.videoAsset = videoAsset
        self.playIconSize = playIconSize
    }

    public var body: some View {
        ZStack {
            if let thumbnailURL = videoAsset.thumbnailURL, let thumbnailImage = UIImage(contentsOfFile: thumbnailURL.path) {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.wsBackground
            }

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
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.button, style: .continuous))
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
