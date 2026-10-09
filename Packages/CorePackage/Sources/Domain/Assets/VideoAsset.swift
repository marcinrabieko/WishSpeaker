import Foundation

/// A generated video card attached to a Wish. Stores metadata and local file
/// references only — never the raw video bytes.
public struct VideoAsset: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let videoFileReference: String
    public let thumbnailReference: String?
    public let duration: TimeInterval
    public let createdAt: Date

    /// Resolves `videoURL`/`thumbnailURL` to these URLs directly instead of looking up
    /// `videoFileReference`/`thumbnailReference` in Documents — for a VideoAsset backed
    /// by files bundled into the app (e.g. a showcase/demo video) rather than one the
    /// user generated. `nil` for every normal, user-generated VideoAsset.
    public let bundledVideoURL: URL?
    public let bundledThumbnailURL: URL?

    public init(
        id: UUID = UUID(),
        videoFileReference: String,
        thumbnailReference: String? = nil,
        duration: TimeInterval,
        createdAt: Date = Date(),
        bundledVideoURL: URL? = nil,
        bundledThumbnailURL: URL? = nil
    ) {
        self.id = id
        self.videoFileReference = videoFileReference
        self.thumbnailReference = thumbnailReference
        self.duration = duration
        self.createdAt = createdAt
        self.bundledVideoURL = bundledVideoURL
        self.bundledThumbnailURL = bundledThumbnailURL
    }
}
