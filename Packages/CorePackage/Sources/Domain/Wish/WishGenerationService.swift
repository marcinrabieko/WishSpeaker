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

public struct LiveWishGenerationService: WishGenerationService {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func generateWishes(for request: WishGenerationRequest) async throws -> WishGenerationResult {
        let dto = GenerateWishesRequestDTO(
            recipientName: resolvedRecipientName(for: request.form),
            occasionKind: request.occasionKind.rawValue,
            context: request.form.note.isEmpty ? nil : request.form.note,
            language: SupportedLanguage.current.rawValue
        )

        let response: WishVariantsDTO = try await apiClient.post("/api/generateWishes", body: dto)

        return WishGenerationResult(
            warm: response.warm,
            natural: response.natural,
            light: response.light
        )
    }

    public func regenerateWish(
        for request: WishGenerationRequest,
        variant: WishVariant,
        previousText: String
    ) async throws -> String {
        let dto = RegenerateWishRequestDTO(
            recipientName: resolvedRecipientName(for: request.form),
            occasionKind: request.occasionKind.rawValue,
            variant: variant.rawValue,
            previousText: previousText,
            context: request.form.note.isEmpty ? nil : request.form.note,
            language: SupportedLanguage.current.rawValue
        )

        let response: RegenerateWishResponseDTO = try await apiClient.post("/api/regenerateWish", body: dto)

        return response.text
    }

    /// The form only ever collects one "who is this for" field (WishForm.relation, e.g.
    /// "Emma, my sister") — recipientName is never populated by the current UI, so this
    /// always falls back to relation.
    private func resolvedRecipientName(for form: WishForm) -> String {
        form.recipientName.isEmpty ? form.relation : form.recipientName
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
