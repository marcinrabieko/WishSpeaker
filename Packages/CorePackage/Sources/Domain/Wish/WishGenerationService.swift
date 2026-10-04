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

public struct LiveWishGenerationService: WishGenerationService {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func generateWishes(for request: WishGenerationRequest) async throws -> WishGenerationResult {
        let dto = GenerateWishesRequestDTO(
            recipientName: request.form.recipientName,
            occasionKind: request.occasionKind.rawValue,
            relation: request.form.relation.isEmpty ? nil : request.form.relation,
            context: request.form.note.isEmpty ? nil : request.form.note,
            language: SupportedLanguage.current.rawValue
        )

        let response: WishVariantsDTO = try await apiClient.post("/api/generateWishes", body: dto)

        return WishGenerationResult(warm: response.warm, natural: response.natural, light: response.light)
    }

    public func regenerateWish(
        for request: WishGenerationRequest,
        variant: WishVariant,
        previousText: String
    ) async throws -> String {
        let dto = RegenerateWishRequestDTO(
            recipientName: request.form.recipientName,
            occasionKind: request.occasionKind.rawValue,
            variant: variant.rawValue,
            previousText: previousText,
            relation: request.form.relation.isEmpty ? nil : request.form.relation,
            context: request.form.note.isEmpty ? nil : request.form.note,
            language: SupportedLanguage.current.rawValue
        )

        let response: RegenerateWishResponseDTO = try await apiClient.post("/api/regenerateWish", body: dto)

        return response.text
    }
}

private struct WishGenerationServiceKey: DependencyKey {
    static var liveValue: any WishGenerationService {
        @Dependency(\.apiEnvironment) var apiEnvironment
        return LiveWishGenerationService(apiClient: APIClient(baseURL: apiEnvironment.baseURL))
    }
}

public extension DependencyValues {
    var wishGenerationService: any WishGenerationService {
        get { self[WishGenerationServiceKey.self] }
        set { self[WishGenerationServiceKey.self] = newValue }
    }
}
