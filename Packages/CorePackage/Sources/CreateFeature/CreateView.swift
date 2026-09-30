import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct CreateView: View {
    @State private var viewModel = CreateViewModel()
    @FocusState private var isTextFieldFocused: Bool

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadata

                wishText

                creationSection

                saveForLaterButton
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.createViewTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .onAppear {
            viewModel.didAppear()
        }
        .navigationDestination(isPresented: $viewModel.navigateToVoice) {
            VoiceVideoPlaceholderView(kind: .voice)
        }
        .navigationDestination(isPresented: $viewModel.navigateToVideoCard) {
            VoiceVideoPlaceholderView(kind: .videoCard)
        }
    }

    private var metadata: some View {
        Text("\(viewModel.occasionTitle) · \(viewModel.variant.displayName)")
            .font(.system(size: 15))
            .foregroundStyle(Color.wsSecondaryText)
    }

    private var wishText: some View {
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

    private var creationSection: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            Text(L10n.createViewMakeItSpecialTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.wsPrimaryText)

            CreationActionRow(
                icon: "waveform",
                title: L10n.createViewVoiceTitle,
                subtitle: L10n.createViewVoiceSubtitle,
                action: { viewModel.didTapVoice() }
            )

            CreationActionRow(
                icon: "video.fill",
                title: L10n.createViewVideoCardTitle,
                subtitle: L10n.createViewVideoCardSubtitle,
                action: { viewModel.didTapVideoCard() }
            )
        }
        .padding(.top, WSSpacing.sm)
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
