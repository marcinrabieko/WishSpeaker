import DesignSystem
import Domain
import Localizations
import SwiftUI

public struct PaywallView: View {
    @State private var viewModel: PaywallViewModel
    @State private var contentHeight: CGFloat = 520.0
    @Environment(\.dismiss) private var dismiss

    private let onPurchased: () -> Void

    public init(kind: PurchaseKind, onPurchased: @escaping () -> Void) {
        _viewModel = State(initialValue: PaywallViewModel(kind: kind))
        self.onPurchased = onPurchased
    }

    public var body: some View {
        // No ScrollView: the sheet is sized to fit this content exactly (see
        // presentationDetents below), so there's never anything to scroll.
        VStack(spacing: WSSpacing.lg) {
            header

            benefitsCard

            purchaseSection
        }
        .padding(.horizontal, WSSpacing.horizontalPadding)
        .padding(.top, WSSpacing.xl)
        .padding(.bottom, WSSpacing.md)
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            contentHeight = height
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing) {
            closeButton
        }
        .wsDecoratedBackground()
        .presentationDetents([.height(contentHeight)])
        .overlay {
            if viewModel.isPurchasing {
                purchasingOverlay
            }
        }
        .interactiveDismissDisabled(viewModel.isPurchasing)
        .alert(L10n.paywallErrorTitle, isPresented: $viewModel.isErrorAlertPresented) {
            Button(L10n.paywallAlertOkButton, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert(L10n.paywallPendingTitle, isPresented: $viewModel.isPendingAlertPresented) {
            Button(L10n.paywallAlertOkButton, role: .cancel) {}
        } message: {
            Text(L10n.paywallPendingMessage)
        }
        .onAppear {
            viewModel.didAppear()
        }
        .onChange(of: viewModel.didPurchase) { _, didPurchase in
            guard didPurchase else {
                return
            }
            onPurchased()
        }
    }

    private var header: some View {
        VStack(spacing: WSSpacing.sm) {
            Image(systemName: viewModel.iconName)
                .font(.system(size: 30.0, weight: .semibold))
                .foregroundStyle(Color.wsPrimary)
                .frame(width: 72.0, height: 72.0)
                .background(Color.wsPrimary.opacity(0.1), in: Circle())
                .padding(.bottom, WSSpacing.xs)

            Text(viewModel.title)
                .font(WSFont.brandTitle(size: 30.0))
                .foregroundColor(.wsPrimaryText)

            Text(viewModel.subtitle)
                .font(.system(size: 16.0))
                .foregroundColor(.wsSecondaryText)
        }
        .multilineTextAlignment(.center)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 14.0) {
            ForEach(viewModel.benefits, id: \.self) { benefit in
                HStack(alignment: .firstTextBaseline, spacing: WSSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.wsPrimary)

                    Text(benefit)
                        .font(.system(size: 16.0))
                        .foregroundStyle(Color.wsPrimaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, WSSpacing.md)
        .padding(.vertical, 20.0)
        .background(Color.wsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                .stroke(Color.wsSoftBorder, lineWidth: 1.0)
        )
        .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
    }

    private var purchaseSection: some View {
        VStack(spacing: WSSpacing.sm) {
            if case .failed = viewModel.priceState {
                Text(L10n.paywallPriceLoadError)
                    .font(.system(size: 14.0))
                    .foregroundStyle(Color.wsSecondaryText)
                    .multilineTextAlignment(.center)

                SecondaryButton(
                    title: L10n.paywallRetryButton,
                    action: {
                        viewModel.didTapRetry()
                    }
                )
            } else {
                PrimaryButton(
                    title: purchaseButtonTitle,
                    action: {
                        viewModel.didTapPurchase()
                    },
                    isEnabled: viewModel.isPurchaseEnabled
                )
            }

            Text(L10n.paywallOneTimePurchaseNote)
                .font(.system(size: 13.0))
                .foregroundStyle(Color.wsSecondaryText)
        }
    }

    private var purchaseButtonTitle: String {
        if case let .loaded(price) = viewModel.priceState {
            L10n.paywallPurchaseButton(price)
        } else {
            L10n.paywallLoadingPrice
        }
    }

    private var closeButton: some View {
        Button(
            action: {
                dismiss()
            },
            label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17.0, weight: .semibold))
                    .foregroundStyle(Color.wsPrimaryText)
                    .frame(width: WSSize.minTapTarget, height: WSSize.minTapTarget)
            }
        )
        .buttonStyle(.plain)
        .modifier(GlassCircleModifier())
        .padding(WSSpacing.sm)
        .disabled(viewModel.isPurchasing)
    }

    private var purchasingOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            ProgressView(L10n.paywallPurchasingMessage)
                .padding(WSSpacing.md)
                .background(Color.wsSurface, in: RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        }
    }
}

/// Same Liquid Glass treatment as `GlassPillButton`'s capsule (true `glassEffect` on
/// iOS 26+, `.ultraThinMaterial` below), just circular for an icon-only button.
private struct GlassCircleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular.interactive(), in: Circle())
        } else {
            content
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}
