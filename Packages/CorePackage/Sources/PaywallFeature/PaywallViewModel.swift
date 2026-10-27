import Dependencies
import Domain
import Localizations
import Observation

enum PaywallPriceState {
    case loading
    case loaded(String)
    case failed
}

@MainActor
@Observable
public final class PaywallViewModel {
    let kind: PurchaseKind

    var priceState: PaywallPriceState = .loading
    var isPurchasing = false
    var isPendingAlertPresented = false
    var isErrorAlertPresented = false
    var errorMessage = ""
    var didPurchase = false

    @ObservationIgnored
    @Dependency(\.purchaseManager)
    private var purchaseManager: PurchaseManager

    public init(kind: PurchaseKind) {
        self.kind = kind
    }

    var iconName: String {
        switch kind {
        case .voice:
            "waveform"
        case .video:
            "video.fill"
        }
    }

    var title: String {
        switch kind {
        case .voice:
            L10n.paywallVoiceTitle
        case .video:
            L10n.paywallVideoTitle
        }
    }

    var subtitle: String {
        switch kind {
        case .voice:
            L10n.paywallVoiceSubtitle
        case .video:
            L10n.paywallVideoSubtitle
        }
    }

    var benefits: [String] {
        switch kind {
        case .voice:
            [
                L10n.paywallVoiceBenefitNarrator,
                L10n.paywallBenefitLibrary,
                L10n.paywallVoiceBenefitShare
            ]
        case .video:
            [
                L10n.paywallVideoBenefitTheme,
                L10n.paywallVideoBenefitSubtitles,
                L10n.paywallBenefitLibrary,
                L10n.paywallVideoBenefitShare
            ]
        }
    }

    var isPurchaseEnabled: Bool {
        if case .loaded = priceState, !isPurchasing {
            true
        } else {
            false
        }
    }

    func didAppear() {
        Task {
            await loadPrice()
        }
    }

    func didTapRetry() {
        priceState = .loading

        Task {
            await loadPrice()
        }
    }

    func didTapPurchase() {
        isPurchasing = true

        Task {
            defer {
                isPurchasing = false
            }

            do throws(PurchaseError) {
                switch try await purchaseManager.purchase(kind) {
                case .purchased:
                    didPurchase = true
                case .pending:
                    isPendingAlertPresented = true
                case .cancelled:
                    break
                }
            } catch {
                errorMessage = message(for: error)
                isErrorAlertPresented = true
            }
        }
    }

    private func loadPrice() async {
        await purchaseManager.loadProducts()

        if let price = purchaseManager.displayPrice(for: kind) {
            priceState = .loaded(price)
        } else {
            priceState = .failed
        }
    }

    private func message(for error: PurchaseError) -> String {
        switch error {
        case .paymentsDisabled:
            L10n.paywallErrorPaymentsDisabled
        case .productUnavailable:
            L10n.paywallErrorProductUnavailable
        case .network:
            L10n.paywallErrorNetwork
        case .failed:
            L10n.paywallErrorGeneric
        }
    }
}
