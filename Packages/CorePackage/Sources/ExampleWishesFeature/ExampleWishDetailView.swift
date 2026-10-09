import AVKit
import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

/// Read-only product demo of the WishDetail experience — no Edit/Save/Copy/Create
/// Voice/Create Video Card/Regenerate, since this wish was never generated or saved
/// by the user. Still offers Share and a video player, matching WishResultView's
/// layout for those two pieces so a demo reads as "a real finished wish", not an
/// inert preview.
struct ExampleWishDetailView: View {
    let wish: Wish

    // Held in @State rather than created inline — recreating AVPlayer(url:) on every
    // body re-render produces a black frame with audio still playing (see
    // WishResultView's same pattern).
    @State private var videoPlayer: AVPlayer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadata

                mediaSection

                Text(wish.text)
                    .font(.system(size: 16))
                    .foregroundColor(.wsPrimaryText)
                    .lineSpacing(5)
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.top, WSSpacing.xxs)
            .padding(.bottom, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(wish.recipient)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
        .task {
            updateVideoPlayerIfNeeded()
        }
    }

    private func updateVideoPlayerIfNeeded() {
        guard let videoURL = wish.videoAsset?.videoURL else {
            videoPlayer = nil
            return
        }

        videoPlayer = AVPlayer(url: videoURL)
    }

    private var metadata: some View {
        Text(WishMetadataText.format(occasionKind: wish.occasionKind, variant: wish.variant))
            .font(.system(size: 15))
            .foregroundColor(.wsSecondaryText)
    }

    @ViewBuilder
    private var mediaSection: some View {
        if wish.videoAsset != nil {
            VideoPlayer(player: videoPlayer)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                        .stroke(Color.wsSoftBorder, lineWidth: 1)
                )
        } else if let voiceAsset = wish.voiceAsset {
            voiceSection(voiceAsset)
        }
    }

    private func voiceSection(_ voiceAsset: VoiceAsset) -> some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: "waveform")
                    .font(.system(size: 13))
                Text(voiceAsset.voiceDisplayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.wsPrimary)

            InlineVoicePlayer(voiceAsset: voiceAsset, audioURL: voiceAsset.audioURL)
                .padding(WSSpacing.sm)
                .background(Color.wsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                        .stroke(Color.wsSoftBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        }
    }

    /// Same Video > Audio > Text menu as WishResultView's shareButton, minus the
    /// text-only ShareLink fast path — every example here always has media, so the
    /// Menu branch is the only one ever reached.
    @ViewBuilder
    private var shareButton: some View {
        Menu {
            Section(L10n.wishDetailShareAsMenuTitle) {
                if let videoURL = wish.videoAsset?.videoURL {
                    ShareLink(item: videoURL) {
                        Label(L10n.wishDetailShareAsVideo, systemImage: "film")
                    }
                }

                if let audioURL = wish.voiceAsset?.audioURL {
                    ShareLink(item: audioURL) {
                        Label(L10n.wishDetailShareAsAudio, systemImage: "waveform")
                    }
                }

                ShareLink(item: wish.text) {
                    Label(L10n.wishDetailShareAsText, systemImage: "text.alignleft")
                }
            }
        } label: {
            Label(L10n.wishDetailShareButton, systemImage: "square.and.arrow.up")
        }
    }
}
