import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct VoiceView: View {
    @State private var viewModel = VoiceViewModel()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadata

                wishTextSection

                voiceSelectionSection
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.top, WSSpacing.md)
            .padding(.bottom, WSSpacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            generateButton
                .padding(.horizontal, WSSpacing.horizontalPadding)
                .padding(.vertical, WSSpacing.sm)
                .background(Color.wsBackground)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.voiceViewTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .onAppear {
            viewModel.didAppear()
        }
    }

    private var metadata: some View {
        Text("\(viewModel.occasionTitle) · \(viewModel.variantDisplayName)")
            .font(.system(size: 15))
            .foregroundStyle(Color.wsSecondaryText)
    }

    private var wishTextSection: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            if viewModel.isShowingText {
                Text(viewModel.wishText)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.wsPrimaryText.opacity(0.85))
                    .lineSpacing(4)
            } else {
                Text(viewModel.wishText)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.wsPrimaryText.opacity(0.85))
                    .lineSpacing(4)
                    .lineLimit(3)
            }

            Button {
                viewModel.didTapShowText()
            } label: {
                Text(viewModel.isShowingText ? L10n.voiceViewHideTextButton : L10n.voiceViewShowTextButton)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.wsPrimary)
            }
            .buttonStyle(.plain)
        }
    }

    private var voiceSelectionSection: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            Text(L10n.voiceViewChooseVoiceSectionTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.wsPrimaryText)

            ForEach(Array(viewModel.voiceRows.enumerated()), id: \.offset) { _, row in
                switch row {
                case .loading:
                    VoiceCardSkeleton()

                case .loaded(let voice):
                    VoiceCard(
                        voice: voice,
                        isSelected: viewModel.selectedProviderVoiceID == voice.providerVoiceID,
                        onSelect: { viewModel.didSelectVoice(voice) }
                    )

                case .failed(let providerVoiceID):
                    VoiceCardError(providerVoiceID: providerVoiceID, onRetry: { viewModel.didTapRetry() })
                }
            }
        }
        .padding(.top, WSSpacing.sm)
    }

    private var generateButton: some View {
        PrimaryButton(
            title: L10n.voiceViewGenerateButton,
            action: {},
            isEnabled: viewModel.isGenerateEnabled
        )
    }
}

private struct VoiceCard: View {
    let voice: VoiceOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: WSSpacing.sm) {
            VoicePreviewPlayer(previewURL: voice.previewURL)

            VStack(alignment: .leading, spacing: 2) {
                Text(voice.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.wsPrimaryText)

                Text(genderLabel)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.wsSecondaryText)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.wsPrimary)
            }
        }
        .padding(WSSpacing.sm)
        .background(isSelected ? Color.wsPrimary.opacity(0.08) : Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(isSelected ? Color.wsPrimary : Color.wsSoftBorder, lineWidth: isSelected ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }

    private var genderLabel: String {
        voice.gender == .male ? L10n.voiceViewGenderMale : L10n.voiceViewGenderFemale
    }
}

private struct VoiceCardSkeleton: View {
    var body: some View {
        HStack(spacing: WSSpacing.sm) {
            Circle()
                .fill(Color.wsSoftBorder)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.wsSoftBorder)
                    .frame(width: 100, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.wsSoftBorder)
                    .frame(width: 60, height: 11)
            }

            Spacer()
        }
        .padding(WSSpacing.sm)
        .background(Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(Color.wsSoftBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        .redacted(reason: .placeholder)
    }
}

private struct VoiceCardError: View {
    let providerVoiceID: String
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: WSSpacing.sm) {
            Text(L10n.voiceViewLoadError)
                .font(.system(size: 14))
                .foregroundStyle(Color.wsSecondaryText)

            Spacer()

            Button(L10n.voiceViewRetryButton, action: onRetry)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.wsPrimary)
        }
        .padding(WSSpacing.sm)
        .background(Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(Color.wsSoftBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
    }
}
