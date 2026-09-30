import Foundation

public struct Wish: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let occasionKind: OccasionKind
    public let occasionTitle: String
    public let recipient: String
    public let context: String?
    public let variant: WishVariant
    public let text: String
    public let language: String
    public let createdAt: Date
    public let updatedAt: Date
    public let selectedPackage: PremiumPackage?
    public let voiceAsset: VoiceAsset?
    public let videoAsset: VideoAsset?

    public init(
        id: UUID = UUID(),
        occasionKind: OccasionKind,
        occasionTitle: String,
        recipient: String,
        context: String? = nil,
        variant: WishVariant,
        text: String,
        language: String = "en",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        selectedPackage: PremiumPackage? = nil,
        voiceAsset: VoiceAsset? = nil,
        videoAsset: VideoAsset? = nil
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
        self.selectedPackage = selectedPackage
        self.voiceAsset = voiceAsset
        self.videoAsset = videoAsset
    }
}
