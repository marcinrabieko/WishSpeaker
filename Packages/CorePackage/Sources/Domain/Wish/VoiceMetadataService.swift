import Dependencies
import Foundation

public enum VoiceMetadataError: Error, Sendable {
    case fetchFailed(providerVoiceID: String)
}

public protocol VoiceMetadataService: Sendable {
    /// Fetches metadata for every curated voice in `VoiceCatalog`. A voice whose
    /// individual fetch fails is omitted rather than failing the whole call — the
    /// Voice screen stays usable as long as at least one curated voice loaded.
    func fetchCuratedVoices() async -> [VoiceOption]
}

public struct MockVoiceMetadataService: VoiceMetadataService {
    public init() {}

    public func fetchCuratedVoices() async -> [VoiceOption] {
        [
            VoiceOption(
                providerVoiceID: VoiceCatalog.maleVoiceID,
                displayName: "Alex",
                gender: .male,
                description: "Friendly, warm narration voice.",
                previewURL: nil
            ),
            VoiceOption(
                providerVoiceID: VoiceCatalog.femaleVoiceID,
                displayName: "Jessica",
                gender: .female,
                description: "Warm, professional voice.",
                previewURL: nil
            )
        ]
    }
}

public struct LiveVoiceMetadataService: VoiceMetadataService {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func fetchCuratedVoices() async -> [VoiceOption] {
        var results: [VoiceOption] = []

        for providerVoiceID in VoiceCatalog.curatedVoiceIDs {
            if let voice = try? await fetchVoice(providerVoiceID: providerVoiceID) {
                results.append(voice)
            }
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
