import Dependencies
import Foundation

public enum VoiceMetadataError: Error, Sendable {
    case fetchFailed(providerVoiceID: String)
}

/// Holds the curated voice catalog in memory for the lifetime of the app process —
/// shared across every Voice/Video screen visit so the user only ever pays the
/// `/api/voices/{id}` network cost once per app launch, not once per visit.
public actor VoiceMetadataCache {
    public static let shared = VoiceMetadataCache()

    private var voices: [VoiceOption]?

    public init() {}

    public func cached() -> [VoiceOption]? {
        voices
    }

    public func store(_ voices: [VoiceOption]) {
        self.voices = voices
    }
}

public protocol VoiceMetadataService: Sendable {
    /// Fetches metadata for every curated voice in `VoiceCatalog`. A voice whose
    /// individual fetch fails is omitted rather than failing the whole call — the
    /// Voice screen stays usable as long as at least one curated voice loaded.
    func fetchCuratedVoices() async -> [VoiceOption]
}

public struct LiveVoiceMetadataService: VoiceMetadataService {
    private let apiClient: APIClient
    private let cache: VoiceMetadataCache

    public init(apiClient: APIClient, cache: VoiceMetadataCache = .shared) {
        self.apiClient = apiClient
        self.cache = cache
    }

    /// Serves the cached catalog on every call after the first — Voice/Video are
    /// reached repeatedly as the user navigates back and forth while drafting a Wish,
    /// and the curated voices never change mid-session, so re-fetching each visit
    /// would just be repeated network latency for identical data.
    public func fetchCuratedVoices() async -> [VoiceOption] {
        if let cached = await cache.cached() {
            return cached
        }

        var results: [VoiceOption] = []

        for providerVoiceID in VoiceCatalog.curatedVoiceIDs {
            if let voice = try? await fetchVoice(providerVoiceID: providerVoiceID) {
                results.append(voice)
            }
        }

        // Only cache a complete catalog — if a voice failed to load (e.g. a
        // transient network error), caching the partial result would make that
        // voice permanently missing for the rest of the session instead of
        // retrying on the next visit.
        if results.count == VoiceCatalog.curatedVoiceIDs.count {
            await cache.store(results)
        }

        return results
    }

    private func fetchVoice(providerVoiceID: String) async throws -> VoiceOption {
        let dto: VoiceMetadataResponseDTO = try await apiClient.get("/api/voices/\(providerVoiceID)")

        var languagePreviewURLs: [String: URL] = [:]
        for verified in dto.verifiedLanguages {
            if let urlString = verified.previewUrl, let url = URL(string: urlString) {
                languagePreviewURLs[verified.language] = url
            }
        }

        return VoiceOption(
            providerVoiceID: dto.voiceId,
            displayName: dto.name,
            gender: VoiceCatalog.gender(forProviderVoiceID: dto.voiceId),
            description: dto.description,
            previewURL: dto.previewUrl.flatMap(URL.init(string:)),
            languagePreviewURLs: languagePreviewURLs
        )
    }
}

private struct VoiceMetadataServiceKey: DependencyKey {
    static var liveValue: any VoiceMetadataService {
        @Dependency(\.apiEnvironment) var apiEnvironment
        return LiveVoiceMetadataService(apiClient: APIClient(baseURL: apiEnvironment.baseURL))
    }
}

public extension DependencyValues {
    var voiceMetadataService: any VoiceMetadataService {
        get { self[VoiceMetadataServiceKey.self] }
        set { self[VoiceMetadataServiceKey.self] = newValue }
    }
}
