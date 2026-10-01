import Foundation
import SwiftData

/// SwiftData-backed storage for a persisted Wish. Kept separate from the domain `Wish`
/// struct (used everywhere else in the app) so the rest of the codebase keeps working
/// with a plain Sendable value type — only WishLibraryManager maps between the two.
@Model
public final class WishModel {
    @Attribute(.unique) public var id: UUID
    public var occasionKind: String
    public var occasionTitle: String
    public var recipient: String
    public var context: String?
    public var variant: String
    public var text: String
    public var language: String
    public var createdAt: Date
    public var updatedAt: Date

    public var selectedPackageID: UUID?
    public var selectedPackageName: String?
    public var selectedPackageDescription: String?
    public var selectedPackagePrice: Double?
    public var selectedPackageRecommended: Bool?

    public var voiceAssetID: UUID?
    public var voiceAudioFileReference: String?
    public var voiceIdentifier: String?
    public var voiceDisplayName: String?
    public var voiceDuration: TimeInterval?
    public var voiceCreatedAt: Date?

    public var videoAssetID: UUID?
    public var videoFileReference: String?
    public var videoThumbnailReference: String?
    public var videoDuration: TimeInterval?
    public var videoCreatedAt: Date?

    public init(
        id: UUID,
        occasionKind: String,
        occasionTitle: String,
        recipient: String,
        context: String?,
        variant: String,
        text: String,
        language: String,
        createdAt: Date,
        updatedAt: Date,
        selectedPackageID: UUID? = nil,
        selectedPackageName: String? = nil,
        selectedPackageDescription: String? = nil,
        selectedPackagePrice: Double? = nil,
        selectedPackageRecommended: Bool? = nil,
        voiceAssetID: UUID? = nil,
        voiceAudioFileReference: String? = nil,
        voiceIdentifier: String? = nil,
        voiceDisplayName: String? = nil,
        voiceDuration: TimeInterval? = nil,
        voiceCreatedAt: Date? = nil,
        videoAssetID: UUID? = nil,
        videoFileReference: String? = nil,
        videoThumbnailReference: String? = nil,
        videoDuration: TimeInterval? = nil,
        videoCreatedAt: Date? = nil
    ) {
        self.id = id
        self.occasionKind = occasionKind
        self.occasionTitle = occasionTitle
        self.recipient = recipient
        self.context = context
        self.variant = variant
        self.text = text
        self.language = language
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.selectedPackageID = selectedPackageID
        self.selectedPackageName = selectedPackageName
        self.selectedPackageDescription = selectedPackageDescription
        self.selectedPackagePrice = selectedPackagePrice
        self.selectedPackageRecommended = selectedPackageRecommended
        self.voiceAssetID = voiceAssetID
        self.voiceAudioFileReference = voiceAudioFileReference
        self.voiceIdentifier = voiceIdentifier
        self.voiceDisplayName = voiceDisplayName
        self.voiceDuration = voiceDuration
        self.voiceCreatedAt = voiceCreatedAt
        self.videoAssetID = videoAssetID
        self.videoFileReference = videoFileReference
        self.videoThumbnailReference = videoThumbnailReference
        self.videoDuration = videoDuration
        self.videoCreatedAt = videoCreatedAt
    }
}
