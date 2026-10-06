import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct CreateView: View {
    @State private var viewModel = CreateViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.createFlowPath) private var createFlowPath

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadata

                if viewModel.voiceAsset != nil {
                    voiceSection
                    wishText
                } else {
                    wishText
                }

                creationSection

                if viewModel.voiceAsset != nil {
                    autoSavedDisclaimer
                } else {
                    saveForLaterButton
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.createViewTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton(customAction: { viewModel.didTapBack(path: createFlowPath) })
        .onAppear {
            viewModel.didAppear()
        }
    }

    private var metadata: some View {
        Text("\(viewModel.occasionTitle) · \(viewModel.variant.displayName)")
            .font(.system(size: 15))
            .foregroundStyle(Color.wsSecondaryText)
    }

    @ViewBuilder
    private var wishText: some View {
        if viewModel.voiceAsset != nil {
            readOnlyWishText
        } else {
            editableWishText
        }
    }

    /// Once a voice is generated, the text that produced it must stay fixed — editing
    /// it here would silently desync the written text from the recorded audio.
    private var readOnlyWishText: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            Text(viewModel.draftText)
                .font(.system(size: 16))
                .foregroundStyle(Color.wsPrimaryText)
                .lineSpacing(5)
                .lineLimit(viewModel.isShowingFullText ? nil : 2)

            Button {
                viewModel.didTapShowFullText()
            } label: {
                Text(viewModel.isShowingFullText ? L10n.voiceViewHideTextButton : L10n.voiceViewShowTextButton)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.wsPrimary)
            }
            .buttonStyle(.plain)
        }
    }

    private var editableWishText: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            if viewModel.isEditing {
                TextEditor(text: $viewModel.draftText)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.wsPrimaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true
                    }
            } else {
                Text(viewModel.draftText)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.wsPrimaryText)
                    .lineSpacing(5)
            }

            editButton
        }
    }

    private var editButton: some View {
        Button {
            if viewModel.isEditing {
                viewModel.didTapDoneEditing()
            } else {
                viewModel.didTapEdit()
            }
        } label: {
            Label(
                viewModel.isEditing ? L10n.createViewEditDoneButton : L10n.createViewEditButton,
                systemImage: viewModel.isEditing ? "checkmark" : "pencil"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.wsPrimaryText.opacity(0.75))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var voiceSection: some View {
        if let voiceAsset = viewModel.voiceAsset {
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

    private var creationSection: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            Text(L10n.createViewMakeItSpecialTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.wsPrimaryText)

            if viewModel.voiceAsset == nil {
                CreationActionRow(
                    icon: "waveform",
                    title: L10n.createViewVoiceTitle,
                    subtitle: L10n.createViewVoiceSubtitle,
                    action: { viewModel.didTapVoice(path: createFlowPath) }
                )
            }

            CreationActionRow(
                icon: "video.fill",
                title: L10n.createViewVideoCardTitle,
                subtitle: L10n.createViewVideoCardSubtitle,
                action: { viewModel.didTapVideoCard(path: createFlowPath) }
            )
        }
        .padding(.top, WSSpacing.sm)
    }

    private var autoSavedDisclaimer: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
            Text(L10n.createViewAutoSavedDisclaimer)
                .font(.system(size: 12))
        }
        .foregroundStyle(Color.wsSecondaryText)
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
        .padding(.top, WSSpacing.xs)
    }

    private var saveForLaterButton: some View {
        Button {
            viewModel.didTapSaveForLater()
        } label: {
            Label(
                viewModel.isSaved ? L10n.createViewSavedConfirmation : L10n.createViewSaveForLaterButton,
                systemImage: viewModel.isSaved ? "bookmark.fill" : "bookmark"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(viewModel.isSaved ? Color.wsPrimary : Color.wsSecondaryText)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, WSSpacing.xs)
    }
}
