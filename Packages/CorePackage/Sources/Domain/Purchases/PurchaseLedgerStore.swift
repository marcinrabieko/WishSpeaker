import Foundation
import Security

/// Paid-for generations not yet spent, plus the transactions already granted —
/// the latter makes granting idempotent, since the same transaction can arrive both
/// from `purchase()` and from `Transaction.updates`/`Transaction.unfinished`.
struct PurchaseLedger: Codable {
    var unusedGenerations: [String: Int] = [:]
    var processedTransactionIDs: Set<UInt64> = []
}

/// Keychain-backed (not UserDefaults) so a paid-but-unused generation survives an app
/// reinstall.
struct PurchaseLedgerStore: Sendable {
    private let service = "com.rabieko.wishspeaker"
    private let account = "purchase_ledger"

    func load() -> PurchaseLedger {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let ledger = try? JSONDecoder().decode(PurchaseLedger.self, from: data)
        else {
            return PurchaseLedger()
        }

        return ledger
    }

    func save(_ ledger: PurchaseLedger) {
        guard let data = try? JSONEncoder().encode(ledger) else {
            return
        }

        let attributes = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
        guard updateStatus == errSecItemNotFound else {
            return
        }

        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        _ = SecItemAdd(query as CFDictionary, nil)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
