import DesignSystem
import Domain
import Localizations
import PackageSelectionFeature
import SwiftUI

public struct WishesView: View {
    @State private var viewModel = WishesViewModel()

    public init() {}

    public var body: some View {
        Group {
            switch viewModel.loadState {
            case .loading:
                loadingView

            case .failed:
                errorView

            case .loaded:
                contentView
            }
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.wishesTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .onAppear {
            viewModel.didAppear()
        }
        .navigationDestination(isPresented: $viewModel.navigateToNextStep) {
            PackageSelectionView()
        }
    }

    private var loadingView: some View {
        VStack(spacing: WSSpacing.sm) {
            Spacer()

            ProgressView()
                .controlSize(.large)
                .tint(.wsPrimary)

            Text(L10n.wishesLoadingMessage)
                .font(.system(size: 15))
                .foregroundStyle(Color.wsSecondaryText)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: WSSpacing.sm) {
            Spacer()

            Text(L10n.wishesGenerationErrorTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.wsPrimaryText)

            Text(L10n.wishesGenerationErrorMessage)
                .font(.system(size: 15))
                .foregroundStyle(Color.wsSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, WSSpacing.lg)

            SecondaryButton(title: L10n.wishesRetryButton) {
                viewModel.didTapRetry()
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.top, WSSpacing.sm)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: WSSpacing.sm) {
                Text(L10n.wishesSubtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.wsSecondaryText)

                ForEach(WishVariant.allCases, id: \.self) { variant in
                    WishCandidateCard(
                        variant: variant,
                        text: viewModel.wishes?.text(for: variant) ?? "",
                        isExpanded: viewModel.expandedVariant == variant,
                        isRegenerating: viewModel.regeneratingVariant == variant,
                        regenerationFailed: viewModel.regenerationErrorVariant == variant,
                        isCopied: viewModel.copiedVariant == variant,
                        isSaved: viewModel.savedVariants.contains(variant),
                        onToggle: { viewModel.didTapToggle(variant) },
                        onCopy: { viewModel.didTapCopy(variant) },
                        onSave: { viewModel.didTapSave(variant) },
                        onRegenerate: { viewModel.didTapRegenerate(variant) },
                        onUseThisWish: { viewModel.didTapUseThisWish(variant) }
                    )
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.top, WSSpacing.xs)
            .padding(.bottom, WSSpacing.lg)
        }
    }
}

private struct WishCandidateCard: View {
    let variant: WishVariant
    let text: String
    let isExpanded: Bool
    let isRegenerating: Bool
    let regenerationFailed: Bool
    let isCopied: Bool
    let isSaved: Bool
    let onToggle: () -> Void
    let onCopy: () -> Void
    let onSave: () -> Void
    let onRegenerate: () -> Void
    let onUseThisWish: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            header

            if isRegenerating {
                HStack(spacing: WSSpacing.xs) {
                    ProgressView()
                        .tint(.wsPrimary)

                    Text(L10n.wishesLoadingMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.wsSecondaryText)
                }
                .padding(.vertical, WSSpacing.xs)
            } else {
                Text(text)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.wsPrimaryText)
                    .lineSpacing(5)
                    .lineLimit(isExpanded ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isExpanded {
                            onToggle()
                        }
                    }

                if regenerationFailed {
                    Text(L10n.wishesRegenerateErrorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.wsPrimary)
                }

                if isExpanded {
                    expandedActions
                }
            }
        }
        .padding(WSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(Color.wsSoftBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    private var header: some View {
        HStack(spacing: WSSpacing.xs) {
            Image(systemName: variant.iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.wsPrimary)

            Text(variant.displayName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.wsPrimaryText)

            Spacer()

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.wsSecondaryText)
        }
        .frame(minHeight: WSSize.minTapTarget)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }

    private var expandedActions: some View {
        VStack(spacing: WSSpacing.sm) {
            HStack(spacing: 0) {
                TertiaryActionButton(
                    title: isCopied ? L10n.wishesCopiedConfirmation : L10n.wishesCopyButton,
                    icon: isCopied ? "checkmark" : "doc.on.doc",
                    isHighlighted: isCopied,
                    action: onCopy
                )

                actionDivider

                TertiaryActionButton(
                    title: isSaved ? L10n.wishesSavedConfirmation : L10n.wishesSaveButton,
                    icon: isSaved ? "bookmark.fill" : "bookmark",
                    isHighlighted: isSaved,
                    action: onSave
                )

                actionDivider

                TertiaryActionButton(
                    title: L10n.wishesRegenerateButton,
                    icon: "arrow.clockwise",
                    isHighlighted: false,
                    action: onRegenerate,
                    isDisabled: isRegenerating
                )
            }

            PrimaryButton(title: L10n.wishesUseThisWishButton, action: onUseThisWish)
        }
        .padding(.top, WSSpacing.xxs)
    }

    private var actionDivider: some View {
        Rectangle()
            .fill(Color.wsSoftBorder)
            .frame(width: 1, height: 24)
    }
}

private struct TertiaryActionButton: View {
    let title: String
    let icon: String
    let isHighlighted: Bool
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))

                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(isHighlighted ? Color.wsPrimary : Color.wsPrimaryText.opacity(0.75))
            .frame(maxWidth: .infinity, minHeight: WSSize.minTapTarget)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
        .contentShape(Rectangle())
    }
}
