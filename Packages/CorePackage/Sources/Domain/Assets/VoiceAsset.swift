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
    /// Video, so speech (and its alignment) never needs to be re-synthesized through
    /// ElevenLabs just to resolve subtitle timing. `nil` for a VoiceAsset created
    /// before this field existed.
    public let wordTimestampsFileReference: String?

    /// The ElevenLabs voice this audio was synthesized with — lets Video generation
    /// tell whether this recording matches the voice currently selected there.
    /// `nil` for a VoiceAsset created before this field existed.
    public let providerVoiceID: String?

    public init(
        id: UUID = UUID(),
        audioFileReference: String,
        voiceIdentifier: String,
        voiceDisplayName: String,
        duration: TimeInterval,
        createdAt: Date = Date(),
        wordTimestampsFileReference: String? = nil,
        providerVoiceID: String? = nil
    ) {
        self.id = id
        self.audioFileReference = audioFileReference
        self.voiceIdentifier = voiceIdentifier
        self.voiceDisplayName = voiceDisplayName
        self.duration = duration
        self.createdAt = createdAt
        self.wordTimestampsFileReference = wordTimestampsFileReference
        self.providerVoiceID = providerVoiceID
    }
}
