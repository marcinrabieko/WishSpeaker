import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct VideoView: View {
    @State private var viewModel = VideoViewModel()
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                metadata

                wishTextSection

                voiceSelectionSection
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.top, WSSpacing.xxs)
            .padding(.bottom, WSSpacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            generateButton
                .padding(.horizontal, WSSpacing.horizontalPadding)
                .padding(.vertical, WSSpacing.sm)
                .background(Color.wsBackground)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.videoViewTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .onAppear {
            viewModel.didAppear()
        }
        .onChange(of: viewModel.navigateBackAfterGeneration) { _, isNavigatingBack in
            guard isNavigatingBack else { return }
            dismiss()
        }
    }

    private var metadata: some View {
        Text("\(viewModel.occasionTitle) · \(viewModel.variantDisplayName)")
            .font(.system(size: 15))
            .foregroundStyle(Color.wsSecondaryText)
    }

    private var wishTextSection: some View {
        Text(viewModel.wishText)
            .font(.system(size: 15))
            .foregroundStyle(Color.wsPrimaryText.opacity(0.85))
            .lineSpacing(4)
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
                        isSelected: viewModel.selectedVoice?.id == voice.id,
                        onSelect: { viewModel.didSelectVoice(voice) }
                    )

                case .failed(let providerVoiceID):
                    VoiceCardError(providerVoiceID: providerVoiceID, onRetry: { viewModel.didTapRetry() })
                }
            }

            if let generationError = viewModel.generationError {
                Text(generationError)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.wsPrimary)
            }
        }
        .padding(.top, WSSpacing.sm)
    }

    private var generateButton: some View {
        PrimaryButton(
            title: viewModel.isGenerating ? "" : L10n.videoViewGenerateButton,
            action: { viewModel.didTapGenerate() },
            isEnabled: viewModel.isGenerateEnabled
        )
        .overlay {
            if viewModel.isGenerating {
                ProgressView()
                    .tint(.white)
            }
        }
    }
}
