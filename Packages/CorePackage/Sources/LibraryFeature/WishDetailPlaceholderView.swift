import AVKit
import CreateFeature
import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI
import UIKit

/// The detail screen for a saved Wish. Copy/Edit are live; Create Voice/Create Video
/// Card are clean navigation boundaries for a future premium creation flow.
struct WishDetailPlaceholderView: View {
    @State private var viewModel: WishDetailViewModel
    @State private var isCopied = false
    @State private var isEditing = false
    @State private var navigateToVoice = false
    @State private var navigateToVideo = false

    // Held in @State rather than created inline — see CreateView's own videoPlayer
    // property for why recreating AVPlayer(url:) on every body re-render produces a
    // black frame with audio still playing.
    @State private var videoPlayer: AVPlayer?

    init(wish: Wish) {
        _viewModel = State(initialValue: WishDetailViewModel(wish: wish))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadata

                mediaSection

                Text(viewModel.wish.text)
                    .font(.system(size: 16))
                    .foregroundColor(.wsPrimaryText)
                    .lineSpacing(5)

                textActions

                if viewModel.wish.videoAsset == nil {
                    createSomethingSpecialSection
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(viewModel.wish.recipient)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
        .onAppear {
            viewModel.didAppear()
        }
        .onChange(of: viewModel.wish.videoAsset?.id) { _, _ in
            updateVideoPlayerIfNeeded()
        }
        .task {
            updateVideoPlayerIfNeeded()
        }
        .sheet(isPresented: $isEditing) {
            EditWishSheet(text: viewModel.wish.text) { newText in
                viewModel.didSaveEditedText(newText)
            }
        }
        .navigationDestination(isPresented: $navigateToVoice) {
            VoiceView()
        }
        .navigationDestination(isPresented: $navigateToVideo) {
            VideoView()
        }
    }

    /// Creates the player once per video asset (identified by the asset's own id, not
    /// just "is there a video") — covers both the initial appearance and returning from
    /// VideoView having just added a video to a Wish that didn't have one before.
    private func updateVideoPlayerIfNeeded() {
        guard let videoURL = viewModel.wish.videoAsset?.videoURL else {
            videoPlayer = nil
            return
        }

        videoPlayer = AVPlayer(url: videoURL)
    }

    /// Three distinct ShareLinks rather than one generic one — ShareLink's `item`
    /// closure is tied to a single Transferable type per call, and video/audio file
    /// URLs vs. plain wish text aren't unifiable without losing the "share the actual
    /// local file, never regenerate/re-encode/upload" behavior for media. Renders
    /// nothing when the referenced media file doesn't exist on disk — the "file
    /// unavailable" state is already communicated via the overlay in `mediaSection`,
    /// so a disabled/erroring toolbar button would just repeat that message.
    @ViewBuilder
    private var shareButton: some View {
        if let videoURL = viewModel.wish.videoAsset?.videoURL {
            ShareLink(item: videoURL) {
                Label(L10n.wishDetailShareButton, systemImage: "square.and.arrow.up")
            }
        } else if let audioURL = viewModel.wish.voiceAsset?.audioURL {
            ShareLink(item: audioURL) {
                Label(L10n.wishDetailShareButton, systemImage: "square.and.arrow.up")
            }
        } else if viewModel.wish.videoAsset == nil && viewModel.wish.voiceAsset == nil {
            ShareLink(item: viewModel.wish.text) {
                Label(L10n.wishDetailShareButton, systemImage: "square.and.arrow.up")
            }
        }
    }

    private var metadata: some View {
        Text(
            WishMetadataText.format(
                occasionKind: viewModel.wish.occasionKind,
                variant: viewModel.wish.variant,
                date: viewModel.wish.createdAt
            )
        )
        .font(.system(size: 15))
        .foregroundColor(.wsSecondaryText)
    }

    @ViewBuilder
    private var mediaSection: some View {
        if let videoAsset = viewModel.wish.videoAsset {
            VideoPlayer(player: videoPlayer)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                        .stroke(Color.wsSoftBorder, lineWidth: 1)
                )
                .overlay {
                    if videoAsset.videoURL == nil {
                        mediaUnavailableOverlay
                    }
                }
        } else if let voiceAsset = viewModel.wish.voiceAsset {
            VStack(alignment: .leading, spacing: WSSpacing.xs) {
                Text(L10n.wishDetailVoiceSectionTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.wsSecondaryText)
                    .textCase(.uppercase)

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
    }

    private var mediaUnavailableOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)

            Label(L10n.wishDetailMediaUnavailable, systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
    }

    private var textActions: some View {
        HStack(spacing: WSSpacing.md) {
            Button {
                UIPasteboard.general.string = viewModel.wish.text
                isCopied = true

                Task {
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    isCopied = false
                }
            } label: {
                Label(
                    isCopied ? L10n.wishDetailCopiedConfirmation : L10n.wishDetailCopyButton,
                    systemImage: isCopied ? "checkmark" : "doc.on.doc"
                )
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isCopied ? .wsPrimary : .wsPrimaryText.opacity(0.75))
            }
            .buttonStyle(.plain)

            if viewModel.wish.voiceAsset == nil && viewModel.wish.videoAsset == nil {
                Button {
                    isEditing = true
                } label: {
                    Label(L10n.wishDetailEditButton, systemImage: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.wsPrimaryText.opacity(0.75))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var createSomethingSpecialSection: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            Text(L10n.wishDetailCreateSomethingSpecialTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.wsPrimaryText)

            if viewModel.wish.voiceAsset == nil {
                CreationActionRow(
                    icon: "waveform",
                    title: L10n.wishDetailCreateVoiceButton,
                    subtitle: L10n.wishDetailCreateVoiceSubtitle
                ) {
                    viewModel.didTapCreateVoice()
                    navigateToVoice = true
                }
            }

            CreationActionRow(
                icon: "video.fill",
                title: L10n.wishDetailCreateVideoButton,
                subtitle: L10n.wishDetailCreateVideoSubtitle
            ) {
                viewModel.didTapCreateVideo()
                navigateToVideo = true
            }
        }
        .padding(.top, WSSpacing.sm)
    }
}

private struct EditWishSheet: View {
    let initialText: String
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: String

    init(text: String, onSave: @escaping (String) -> Void) {
        initialText = text
        self.onSave = onSave
        _draft = State(initialValue: text)
    }

    var body: some View {
        NavigationStack {
            TextEditor(text: $draft)
                .font(.system(size: 16))
                .padding(WSSpacing.sm)
                .background(Color.wsBackground)
                .navigationTitle(L10n.wishDetailEditSheetTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(L10n.wishDetailEditCancelButton) {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button(L10n.wishDetailEditSaveButton) {
                            onSave(draft)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
        }
    }
}
