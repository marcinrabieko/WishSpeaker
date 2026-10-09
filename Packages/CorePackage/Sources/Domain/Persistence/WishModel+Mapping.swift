import Foundation

extension WishModel {
    convenience init(wish: Wish) {
        self.init(
            id: wish.id,
            occasionKind: wish.occasionKind.rawValue,
            occasionTitle: wish.occasionTitle,
            recipient: wish.recipient,
            context: wish.context,
            variant: wish.variant.rawValue,
            text: wish.text,
            language: wish.language,
            createdAt: wish.createdAt,
            updatedAt: wish.updatedAt,
            selectedPackageID: wish.selectedPackage?.id,
            selectedPackageName: wish.selectedPackage?.name,
            selectedPackageDescription: wish.selectedPackage?.description,
            selectedPackagePrice: wish.selectedPackage?.price,
            selectedPackageRecommended: wish.selectedPackage?.recommended,
            voiceAssetID: wish.voiceAsset?.id,
            voiceAudioFileReference: wish.voiceAsset?.audioFileReference,
            voiceIdentifier: wish.voiceAsset?.voiceIdentifier,
            voiceDisplayName: wish.voiceAsset?.voiceDisplayName,
            voiceDuration: wish.voiceAsset?.duration,
            voiceCreatedAt: wish.voiceAsset?.createdAt,
            voiceWordTimestampsFileReference: wish.voiceAsset?.wordTimestampsFileReference,
            videoAssetID: wish.videoAsset?.id,
            videoFileReference: wish.videoAsset?.videoFileReference,
            videoThumbnailReference: wish.videoAsset?.thumbnailReference,
            videoDuration: wish.videoAsset?.duration,
            videoCreatedAt: wish.videoAsset?.createdAt
        )
    }

    /// Updates every stored property in place from `wish` — used to keep an existing
    /// Library row in sync rather than inserting a duplicate model instance.
    func update(from wish: Wish) {
        occasionKind = wish.occasionKind.rawValue
        occasionTitle = wish.occasionTitle
        recipient = wish.recipient
        context = wish.context
        variant = wish.variant.rawValue
        text = wish.text
        language = wish.language
        createdAt = wish.createdAt
        updatedAt = wish.updatedAt

        selectedPackageID = wish.selectedPackage?.id
        selectedPackageName = wish.selectedPackage?.name
        selectedPackageDescription = wish.selectedPackage?.description
        selectedPackagePrice = wish.selectedPackage?.price
        selectedPackageRecommended = wish.selectedPackage?.recommended

        voiceAssetID = wish.voiceAsset?.id
        voiceAudioFileReference = wish.voiceAsset?.audioFileReference
        voiceIdentifier = wish.voiceAsset?.voiceIdentifier
        voiceDisplayName = wish.voiceAsset?.voiceDisplayName
        voiceDuration = wish.voiceAsset?.duration
        voiceCreatedAt = wish.voiceAsset?.createdAt
        voiceWordTimestampsFileReference = wish.voiceAsset?.wordTimestampsFileReference

        videoAssetID = wish.videoAsset?.id
        videoFileReference = wish.videoAsset?.videoFileReference
        videoThumbnailReference = wish.videoAsset?.thumbnailReference
        videoDuration = wish.videoAsset?.duration
        videoCreatedAt = wish.videoAsset?.createdAt
    }

    var asWish: Wish {
        Wish(
            id: id,
            occasionKind: OccasionKind(rawValue: occasionKind) ?? .other,
            occasionTitle: occasionTitle,
            recipient: recipient,
            context: context,
            variant: WishVariant(rawValue: variant) ?? .natural,
            text: text,
            language: language,
            createdAt: createdAt,
            updatedAt: updatedAt,
            selectedPackage: selectedPackageAsPremiumPackage,
            voiceAsset: voiceAssetAsVoiceAsset,
            videoAsset: videoAssetAsVideoAsset
        )
    }

    private var selectedPackageAsPremiumPackage: PremiumPackage? {
        guard
            let selectedPackageID,
            let selectedPackageName,
            let selectedPackageDescription,
            let selectedPackagePrice
        else {
            return nil
        }

        return PremiumPackage(
            id: selectedPackageID,
            name: selectedPackageName,
            description: selectedPackageDescription,
            price: selectedPackagePrice,
            recommended: selectedPackageRecommended ?? false
        )
    }

    private var voiceAssetAsVoiceAsset: VoiceAsset? {
        guard
            let voiceAssetID,
            let voiceAudioFileReference,
            let voiceIdentifier,
            let voiceDisplayName,
            let voiceDuration,
            let voiceCreatedAt
        else {
            return nil
        }

        return VoiceAsset(
            id: voiceAssetID,
            audioFileReference: voiceAudioFileReference,
            voiceIdentifier: voiceIdentifier,
            voiceDisplayName: voiceDisplayName,
            duration: voiceDuration,
            createdAt: voiceCreatedAt,
            wordTimestampsFileReference: voiceWordTimestampsFileReference
        )
    }

    private var videoAssetAsVideoAsset: VideoAsset? {
        guard
            let videoAssetID,
            let videoFileReference,
            let videoDuration,
            let videoCreatedAt
        else {
            return nil
        }

        return VideoAsset(
            id: videoAssetID,
            videoFileReference: videoFileReference,
            thumbnailReference: videoThumbnailReference,
            duration: videoDuration,
            createdAt: videoCreatedAt
        )
    }
}
