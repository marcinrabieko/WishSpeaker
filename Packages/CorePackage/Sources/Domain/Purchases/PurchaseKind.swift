import Foundation

/// A single paid generation, sold as a consumable In-App Purchase.
public enum PurchaseKind: String, CaseIterable, Codable, Sendable {
    case voice
    case video

    var productID: String {
        switch self {
        case .voice:
            "com.rabieko.wishspeaker.voice"
        case .video:
            "com.rabieko.wishspeaker.video"
        }
    }

    init?(productID: String) {
        guard let kind = Self.allCases.first(where: { $0.productID == productID }) else {
            return nil
        }

        self = kind
    }
}

public enum PurchaseOutcome: Sendable {
    case purchased
    case cancelled
    case pending
}

public enum PurchaseError: Error, Sendable {
    case paymentsDisabled
    case productUnavailable
    case network
    case failed
}
