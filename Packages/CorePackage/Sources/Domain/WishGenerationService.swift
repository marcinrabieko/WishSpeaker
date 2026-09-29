import Dependencies
import Foundation

public struct WishGenerationRequest: Sendable {
    public let form: WishForm
    public let occasionKind: OccasionKind

    public init(form: WishForm, occasionKind: OccasionKind) {
        self.form = form
        self.occasionKind = occasionKind
    }
}

public protocol WishGenerationService: Sendable {
    func generateWishes(for request: WishGenerationRequest) async throws -> WishGenerationResult

    func regenerateWish(
        for request: WishGenerationRequest,
        variant: WishVariant,
        previousText: String
    ) async throws -> String
}

public struct MockWishGenerationService: WishGenerationService {
    public init() {}

    public func generateWishes(for request: WishGenerationRequest) async throws -> WishGenerationResult {
        try await Task.sleep(nanoseconds: 900_000_000)

        return WishGenerationResult(
            warm: MockWishGenerator.shared.generateWish(request: request, variant: .warm, avoiding: nil),
            natural: MockWishGenerator.shared.generateWish(request: request, variant: .natural, avoiding: nil),
            light: MockWishGenerator.shared.generateWish(request: request, variant: .light, avoiding: nil)
        )
    }

    public func regenerateWish(
        for request: WishGenerationRequest,
        variant: WishVariant,
        previousText: String
    ) async throws -> String {
        try await Task.sleep(nanoseconds: 700_000_000)

        return MockWishGenerator.shared.generateWish(request: request, variant: variant, avoiding: previousText)
    }
}

private struct WishGenerationServiceKey: DependencyKey {
    static var liveValue: any WishGenerationService {
        MockWishGenerationService()
    }
}

public extension DependencyValues {
    var wishGenerationService: any WishGenerationService {
        get { self[WishGenerationServiceKey.self] }
        set { self[WishGenerationServiceKey.self] = newValue }
    }
}
