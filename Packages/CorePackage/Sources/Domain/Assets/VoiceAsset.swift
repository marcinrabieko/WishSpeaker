import Foundation

/// A generated voice recording attached to a Wish. Stores metadata and local file
/// references only — never the raw audio bytes.
public struct VoiceAsset: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let audioFileReference: String
    public let voiceIdentifier: String
    public let voiceDisplayName: String
    public let duration: TimeInterval
    public let createdAt: Date

    /// Word-level timing for `audioFileReference`'s speech, saved as a sidecar JSON
    /// file at generation time — reused verbatim when this Wish later generates a
    /// Video, so the backend never needs to re-synthesize speech (and its alignment)
    /// through ElevenLabs just to resolve subtitle timing. `nil` for a VoiceAsset
    /// created before this field existed.
    public let wordTimestampsFileReference: String?

    /// Resolves `audioURL` to this URL directly instead of looking up
    /// `audioFileReference` in Documents — for a VoiceAsset backed by a file bundled
    /// into the app (e.g. a showcase/demo recording) rather than one the user
    /// generated. `nil` for every normal, user-generated VoiceAsset.
    public let bundledAudioURL: URL?

    public init(
        id: UUID = UUID(),
        audioFileReference: String,
        voiceIdentifier: String,
        voiceDisplayName: String,
        duration: TimeInterval,
        createdAt: Date = Date(),
        wordTimestampsFileReference: String? = nil,
        bundledAudioURL: URL? = nil
    ) {
        self.id = id
        self.audioFileReference = audioFileReference
        self.voiceIdentifier = voiceIdentifier
        self.voiceDisplayName = voiceDisplayName
        self.duration = duration
        self.createdAt = createdAt
        self.wordTimestampsFileReference = wordTimestampsFileReference
        self.bundledAudioURL = bundledAudioURL
    }
}
