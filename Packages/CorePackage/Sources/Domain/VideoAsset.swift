import Foundation

/// A generated video card attached to a Wish. Stores metadata and local file
/// references only — never the raw video bytes.
public struct VideoAsset: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let videoFileReference: String
    public let thumbnailReference: String?
    public let duration: TimeInterval
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        videoFileReference: String,
        thumbnailReference: String? = nil,
        duration: TimeInterval,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.videoFileReference = videoFileReference
        self.thumbnailReference = thumbnailReference
        self.duration = duration
        self.createdAt = createdAt
    }
}
