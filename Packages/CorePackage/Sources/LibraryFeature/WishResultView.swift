import AVKit
import CreateFeature
import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI
import UIKit

/// The single result screen for a Wish — reached both by tapping a saved Wish in
/// LibraryView and at the end of the Occasion → Form → Wishes creation flow. The two
/// origins show exactly the same data and the same decisions (copy, edit, share, create
/// voice/video), so they share one view and one WishResultViewModel; `origin` only
/// changes Back's behavior (see WishResultViewModel.didTapBackInCreationFlow).
public struct WishResultView: View {
    @State private var viewModel: WishResultViewModel
    private let origin: WishResultOrigin

    @State private var isCopied = false
    @State private var isJustSaved = false
    @State private var navigateToVoice = false
    @State private var navigateToVideo = false

    @Environment(\.createFlowPath) private var createFlowPath

    // Held in @State rather than created inline — recreating AVPlayer(url:) on every
    // body re-render (e.g. from unrelated @Observable changes) produces a black frame
    // with audio still playing: the video track's decoder never got a chance to finish
    // starting up before being torn down and replaced again.
    @State private var videoPlayer: AVPlayer?

    public init(wish: Wish) {
        _viewModel = State(initialValue: WishResultViewModel(wish: wish))
        origin = .library
    }

    private init(creationFlow: Void) {
        _viewModel = State(initialValue: WishResultViewModel(fromCreationDraft: ()))
        origin = .creationFlow
    }

    /// The `.create` destination at the end of the Occasion → Form → Wishes flow —
    /// finalizes whatever WishCreationManager has been accumulating into a Wish.
    public static func fromCreationFlow() -> WishResultView {
        WishResultView(creationFlow: ())
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadataRow

                mediaSection

                wishTextSection

                if viewModel.wish.videoAsset == nil {
                    createSomethingSpecialSection
                }

                if !viewModel.isSaved || isJustSaved {
                    saveForLaterButton
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(viewModel.wish.recipient)
        .navigationBarTitleDisplayMode(.large)
        .modifier(BackButtonModifier(origin: origin, viewModel: viewModel, path: createFlowPath))
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

    /// Metadata leading, the Copy/Edit glass action group trailing — falls back to
    /// stacking the action group below the metadata (via ViewThatFits) rather than
    /// truncating a long localized occasion name or overlapping it at larger Dynamic
    /// Type sizes, where the single-row layout would no longer fit.
    private var metadataRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: WSSpacing.sm) {
                metadata
                Spacer(minLength: WSSpacing.sm)
                glassActionGroup
            }

            VStack(alignment: .leading, spacing: WSSpacing.xs) {
                metadata
                glassActionGroup
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
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Copy (always) + Edit (only while there's no voice/video yet, since editing text
    /// after generation would desync it from the recorded audio) in one shared glass
    /// capsule. True `glassEffect`/`GlassEffectContainer` on iOS 26+; `.ultraThinMaterial`
    /// is the closest native stand-in below that — never a hand-rolled blur/opacity/
    /// gradient approximation of glass.
    @ViewBuilder
    private var glassActionGroup: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: WSSpacing.xs) {
                HStack(spacing: WSSpacing.xs) {
                    copyButton
                    if canEditText {
                        editButton
                    }
                }
            }
            .glassEffect(.regular, in: Capsule())
        } else {
            HStack(spacing: WSSpacing.xs) {
                copyButton
                if canEditText {
                    editButton
                }
            }
            .background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var canEditText: Bool {
        viewModel.wish.voiceAsset == nil && viewModel.wish.videoAsset == nil
    }

    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = viewModel.wish.text
            isCopied = true

            Task {
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                isCopied = false
            }
        } label: {
            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.wsPrimaryText)
                .frame(width: WSSize.minTapTarget, height: WSSize.minTapTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCopied ? L10n.wishDetailCopiedConfirmation : L10n.wishDetailCopyButton)
    }

    private var editButton: some View {
        Button {
            if viewModel.isEditing {
                viewModel.didSaveEditedText(viewModel.draftText)
                viewModel.isEditing = false
            } else {
                viewModel.draftText = viewModel.wish.text
                viewModel.isEditing = true
            }
        } label: {
            Image(systemName: viewModel.isEditing ? "checkmark" : "pencil")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.wsPrimaryText)
                .frame(width: WSSize.minTapTarget, height: WSSize.minTapTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.isEditing ? L10n.createViewEditDoneButton : L10n.wishDetailEditButton)
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

    /// Once a voice/video is generated, the text that produced it must stay fixed —
    /// editing it here would silently desync the written text from the recorded audio,
    /// so Edit only ever shows up (via glassActionGroup/canEditText) while both are
    /// still nil.
    @ViewBuilder
    private var wishTextSection: some View {
        if viewModel.isEditing {
            TextEditor(text: $viewModel.draftText)
                .font(.system(size: 16))
                .foregroundColor(.wsPrimaryText)
                .lineSpacing(5)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 160)
                // TextEditor adds its own internal inset around the text container
                // (horizontal AND vertical) that Text doesn't have — without canceling
                // both axes, switching into edit mode visibly shifts/rewraps the text
                // and nudges it down relative to the read-only view right above it.
                .padding(.horizontal, -5)
                .padding(.vertical, -8)
        } else {
            Text(viewModel.wish.text)
                .font(.system(size: 16))
                .foregroundColor(.wsPrimaryText)
                .lineSpacing(5)
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

    private var saveForLaterButton: some View {
        Button {
            viewModel.didTapSaveForLater()
            isJustSaved = true

            Task {
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                isJustSaved = false
            }
        } label: {
            Label(
                isJustSaved ? L10n.wishesSavedConfirmation : L10n.createViewSaveForLaterButton,
                systemImage: isJustSaved ? "checkmark" : "bookmark"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(isJustSaved ? Color.wsPrimary : Color.wsSecondaryText)
        }
        .buttonStyle(.plain)
        .disabled(isJustSaved)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, WSSpacing.xs)
    }
}

/// `.wsBackButton()` (plain pop) for a Wish opened from the Library vs.
/// `.wsBackButton(customAction:)` (pop-to-Start once a voice/video exists) for the
/// creation flow — kept as a ViewModifier rather than an inline `if` in `body` because
/// `wsBackButton`'s two overloads aren't both callable from a single `@ViewBuilder` if
/// branch without it.
private struct BackButtonModifier: ViewModifier {
    let origin: WishResultOrigin
    let viewModel: WishResultViewModel
    let path: Binding<NavigationPath>

    func body(content: Content) -> some View {
        switch origin {
        case .library:
            content.wsBackButton()

        case .creationFlow:
            content.wsBackButton(customAction: { viewModel.didTapBackInCreationFlow(path: path) })
        }
    }
}
