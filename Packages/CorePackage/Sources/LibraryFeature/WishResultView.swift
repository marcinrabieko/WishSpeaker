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
    @FocusState private var isTextEditorFocused: Bool

    // Measured from the read-only Text while it's on screen (see wishTextSection), then
    // applied as the TextEditor's own height once editing starts — so entering edit
    // mode doesn't jump to an unrelated fixed minHeight.
    @State private var readOnlyTextHeight: CGFloat = 0

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
                metadata

                mediaSection

                wishTextSection

                // The parent VStack's own spacing (WSSpacing.md = 24pt) already sits
                // between every pair of siblings here — these two paddings only add the
                // few extra points needed to hit the exact 16pt / 32pt specified gaps,
                // rather than re-deriving the full gap from zero.
                textActionsRow
                    .padding(.top, 16 - WSSpacing.md)

                if viewModel.wish.videoAsset == nil {
                    createSomethingSpecialSection
                        .padding(.top, 32 - WSSpacing.md)
                }

                if !viewModel.isSaved || isJustSaved {
                    saveForLaterButton
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.top, WSSpacing.xxs)
            .padding(.bottom, WSSpacing.md)
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

    /// Text-only Wishes share immediately via a plain ShareLink — there's only one
    /// possible format, so a format-picker Menu would be a pointless extra tap. Once a
    /// Wish has audio and/or video, the same toolbar button becomes a Menu offering only
    /// the formats actually available, Video > Audio > Text, so the format picker and
    /// the Share Sheet never both try to present at once — the Share Sheet only opens
    /// after a format is chosen from the Menu.
    ///
    /// Each case gets its own ShareLink rather than one generic call — ShareLink's
    /// `item` closure is tied to a single Transferable type per call, and a video/audio
    /// file URL vs. the plain wish text aren't unifiable without losing the "share the
    /// actual local file, never regenerate/re-encode/upload" behavior for media.
    @ViewBuilder
    private var shareButton: some View {
        let videoURL = viewModel.wish.videoAsset?.videoURL
        let audioURL = viewModel.wish.voiceAsset?.audioURL

        if videoURL == nil && audioURL == nil {
            ShareLink(item: viewModel.wish.text) {
                Label(L10n.wishDetailShareButton, systemImage: "square.and.arrow.up")
            }
        } else {
            Menu {
                Section(L10n.wishDetailShareAsMenuTitle) {
                    if let videoURL {
                        ShareLink(item: videoURL) {
                            Label(L10n.wishDetailShareAsVideo, systemImage: "film")
                        }
                    }

                    if let audioURL {
                        ShareLink(item: audioURL) {
                            Label(L10n.wishDetailShareAsAudio, systemImage: "waveform")
                        }
                    }

                    ShareLink(item: viewModel.wish.text) {
                        Label(L10n.wishDetailShareAsText, systemImage: "text.alignleft")
                    }
                }
            } label: {
                Label(L10n.wishDetailShareButton, systemImage: "square.and.arrow.up")
            }
        }
    }

    /// Pure metadata, full width, independent of any action — Copy/Edit live directly
    /// under the wish text instead (see textActionsRow), since they act on the text,
    /// not on "which occasion/variant/date is this".
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Copy + Edit live directly under the full wish text now, not next to metadata —
    /// each is its own glass pill (icon + label) rather than a shared capsule, so a
    /// Copy-only wish (voice/video already generated) doesn't look like an accidental
    /// lone icon. Left-aligned under the text, never wrapping onto its own row.
    private var textActionsRow: some View {
        HStack(spacing: 8) {
            copyPill

            if canEditText {
                editPill
            }
        }
    }

    private var canEditText: Bool {
        viewModel.wish.voiceAsset == nil && viewModel.wish.videoAsset == nil
    }

    private var copyPill: some View {
        GlassPillButton(
            title: isCopied ? L10n.wishDetailCopiedConfirmation : copyButtonTitle,
            icon: isCopied ? "checkmark" : "doc.on.doc",
            minHeight: 38
        ) {
            UIPasteboard.general.string = viewModel.wish.text
            isCopied = true

            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                isCopied = false
            }
        }
    }

    /// "Copy text" once media exists (Variant C) — disambiguates from copying the
    /// audio/video itself, which Share already covers. Plain "Copy" otherwise
    /// (Variants A/B), where the wish text is the only thing there is to copy.
    private var copyButtonTitle: String {
        canEditText ? L10n.wishDetailCopyButton : L10n.wishDetailCopyTextButton
    }

    private var editPill: some View {
        GlassPillButton(
            title: viewModel.isEditing ? L10n.createViewEditDoneButton : L10n.wishDetailEditButton,
            icon: viewModel.isEditing ? "checkmark" : "pencil",
            minHeight: 38
        ) {
            if viewModel.isEditing {
                viewModel.didSaveEditedText(viewModel.draftText)
                viewModel.isEditing = false
                isTextEditorFocused = false
            } else {
                viewModel.draftText = viewModel.wish.text
                viewModel.isEditing = true
                isTextEditorFocused = true
            }
        }
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
                // frame is sized to readOnlyTextHeight PLUS the vertical inset that
                // the padding below cancels out right after — otherwise the negative
                // padding shrinks the already-matched height a second time and clips
                // the text's last line.
                .frame(height: max(readOnlyTextHeight, 44) + 16)
                // TextEditor adds its own internal inset around the text container
                // (horizontal AND vertical) that Text doesn't have — without canceling
                // both axes, switching into edit mode visibly shifts/rewraps the text
                // and nudges it down relative to the read-only view right above it.
                .padding(.horizontal, -5)
                .padding(.vertical, -8)
                .focused($isTextEditorFocused)
        } else {
            Text(viewModel.wish.text)
                .font(.system(size: 16))
                .foregroundColor(.wsPrimaryText)
                .lineSpacing(5)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { readOnlyTextHeight = proxy.size.height }
                            .onChange(of: proxy.size.height) { _, newHeight in
                                readOnlyTextHeight = newHeight
                            }
                    }
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
