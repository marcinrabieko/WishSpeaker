import Foundation

/// A generated voice recording attached to a Wish. Stores metadata and a local file
/// reference only — never the raw audio bytes.
public struct VoiceAsset: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let audioFileReference: String
    public let voiceIdentifier: String
    public let voiceDisplayName: String
    public let duration: TimeInterval
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        audioFileReference: String,
        voiceIdentifier: String,
        voiceDisplayName: String,
        duration: TimeInterval,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.audioFileReference = audioFileReference
        self.voiceIdentifier = voiceIdentifier
        self.voiceDisplayName = voiceDisplayName
        self.duration = duration
        self.createdAt = createdAt
    }
}
