import Dependencies
import Foundation
import StoreKit

/// StoreKit 2 purchases of single voice/video generations. A purchase only grants an
/// "unused generation"; it's spent via `consumeGeneration(_:)` once generation actually
/// succeeds, so a failed generation can be retried without paying again.
@MainActor
public final class PurchaseManager {
    private var products: [PurchaseKind: Product] = [:]
    private var ledger: PurchaseLedger
    private let ledgerStore = PurchaseLedgerStore()
    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        ledger = ledgerStore.load()
    }

    /// Call once at app launch: picks up Ask to Buy approvals and transactions left
    /// unfinished by a crash/kill between `purchase()` and `finish()`.
    public func start() {
        guard transactionUpdatesTask == nil else {
            return
        }

        transactionUpdatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
            }
        }

        Task { [weak self] in
            for await unfinished in Transaction.unfinished {
                await self?.handle(unfinished)
            }
        }
    }

    public func loadProducts() async {
        guard products.count < PurchaseKind.allCases.count else {
            return
        }

        guard let storeProducts = try? await Product.products(for: PurchaseKind.allCases.map(\.productID)) else {
            return
        }

        for product in storeProducts {
            if let kind = PurchaseKind(productID: product.id) {
                products[kind] = product
            }
        }
    }

    public func displayPrice(for kind: PurchaseKind) -> String? {
        products[kind]?.displayPrice
    }

    public func purchase(_ kind: PurchaseKind) async throws(PurchaseError) -> PurchaseOutcome {
        guard AppStore.canMakePayments else {
            throw .paymentsDisabled
        }

        await loadProducts()

        guard let product = products[kind] else {
            throw .productUnavailable
        }

        let result: Product.PurchaseResult
        do {
            result = try await product.purchase()
        } catch let error as StoreKitError {
            switch error {
            case .userCancelled:
                return .cancelled
            case .networkError:
                throw .network
            default:
                throw .failed
            }
        } catch {
            throw .failed
        }

        switch result {
        case let .success(verification):
            guard case let .verified(transaction) = verification else {
                throw .failed
            }

            grant(transaction)
            await transaction.finish()
            return .purchased
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            throw .failed
        }
    }

    public func hasUnusedGeneration(_ kind: PurchaseKind) -> Bool {
        ledger.unusedGenerations[kind.rawValue, default: 0] > 0
    }

    public func consumeGeneration(_ kind: PurchaseKind) {
        guard hasUnusedGeneration(kind) else {
            return
        }

        ledger.unusedGenerations[kind.rawValue, default: 0] -= 1
        ledgerStore.save(ledger)
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        // Unverified transactions aren't from the App Store — leave them unfinished.
        guard case let .verified(transaction) = result else {
            return
        }

        grant(transaction)
        await transaction.finish()
    }

    private func grant(_ transaction: Transaction) {
        guard let kind = PurchaseKind(productID: transaction.productID),
              transaction.revocationDate == nil,
              !ledger.processedTransactionIDs.contains(transaction.id)
        else {
            return
        }

        ledger.processedTransactionIDs.insert(transaction.id)
        ledger.unusedGenerations[kind.rawValue, default: 0] += 1
        ledgerStore.save(ledger)
    }
}

struct PurchaseManagerKey: DependencyKey {
    static var liveValue: PurchaseManager {
        @MainActor get { PurchaseManager() }
    }
}

public extension DependencyValues {
    var purchaseManager: PurchaseManager {
        get { self[PurchaseManagerKey.self] }
        set { self[PurchaseManagerKey.self] = newValue }
    }
}
