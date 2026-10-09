import Foundation

/// A WishSpeaker-facing voice the user can pick for Voice generation, decoupled from
/// ElevenLabs' own response shape — Views operate on this, never on a raw ElevenLabs DTO.
public struct VoiceOption: Identifiable, Hashable, Sendable {
    public let id: String
    public let providerVoiceID: String
    public let displayName: String
    public let gender: VoiceGender
    public let description: String?
    public let previewURL: URL?
    public let languagePreviewURLs: [String: URL]

    public init(
        providerVoiceID: String,
        displayName: String,
        gender: VoiceGender,
        description: String? = nil,
        previewURL: URL? = nil,
        languagePreviewURLs: [String: URL] = [:]
    ) {
        id = providerVoiceID
        self.providerVoiceID = providerVoiceID
        self.displayName = displayName
        self.gender = gender
        self.description = description
        self.previewURL = previewURL
        self.languagePreviewURLs = languagePreviewURLs
    }

    /// Prefers a preview matching `languageCode` (e.g. "pl") when ElevenLabs has a
    /// verified-language sample for it, falling back to the voice-level preview.
    /// Never fails the caller just because no language-specific preview exists.
    public func previewURL(forLanguageCode languageCode: String) -> URL? {
        languagePreviewURLs[languageCode] ?? previewURL
    }
}

/// The curated WishSpeaker voices — kept centralized here, not scattered through
/// SwiftUI Views, matching the backend's own CURATED_VOICE_IDS allowlist. Male voices
/// first, then female.
public enum VoiceCatalog {
    public static let maleVoiceIDs = ["GzE4TcXfh9rYCU9gVgPp", "1SM7GgM6IMuvQlz2BwM3"]
    public static let femaleVoiceIDs = ["lxYfHSkYm1EzQzGhdbfc", "tnSpp4vdxKPjI9w0GnoV"]

    public static let curatedVoiceIDs = maleVoiceIDs + femaleVoiceIDs

    public static func gender(forProviderVoiceID providerVoiceID: String) -> VoiceGender {
        maleVoiceIDs.contains(providerVoiceID) ? .male : .female
    }
}
