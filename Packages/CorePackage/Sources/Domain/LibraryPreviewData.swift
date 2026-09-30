import Foundation

/// Sample Wishes covering the three Library card states (text-only, voice, video),
/// for SwiftUI previews and development only — never inserted into the user's real
/// WishLibraryManager.
public enum LibraryPreviewData {
    public static let textOnlyBirthdayWish = Wish(
        occasionKind: .birthday,
        occasionTitle: "Birthday",
        recipient: "Emma",
        context: "loves traveling, has a great sense of humor",
        variant: .warm,
        text: """
        Happy Birthday, Emma! I hope this year brings you as much joy and adventure as \
        you bring to everyone around you. Here's to more trips, more laughter, and more \
        unforgettable stories. Wishing you a day as wonderful as you are.
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 2),
        updatedAt: Date(timeIntervalSinceNow: -86_400 * 2)
    )

    public static let voiceBirthdayWish = Wish(
        occasionKind: .birthday,
        occasionTitle: "Birthday",
        recipient: "Michael",
        context: "he just got a promotion he worked hard for",
        variant: .natural,
        text: """
        Michael, happy birthday! It's been a big year for you, and it's wonderful to see \
        all that hard work paying off. I hope today gives you a moment to slow down and \
        enjoy how far you've come. Here's to another great year ahead.
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 5),
        updatedAt: Date(timeIntervalSinceNow: -3_600 * 6),
        voiceAsset: VoiceAsset(
            audioFileReference: "sample_voice_michael_birthday.m4a",
            voiceIdentifier: "warm_male_01",
            voiceDisplayName: "James",
            duration: 42.0,
            createdAt: Date(timeIntervalSinceNow: -3_600 * 6)
        )
    )

    public static let videoWeddingWish = Wish(
        occasionKind: .wedding,
        occasionTitle: "Wedding",
        recipient: "Emma & Michael",
        context: "they met while traveling and love hiking together",
        variant: .light,
        text: """
        Emma & Michael, what a joy to celebrate the two of you today! From spontaneous \
        trips to quiet mountain trails, you've built a life together that's full of \
        adventure — and now the biggest one yet is just beginning. Wishing you a \
        marriage as joyful and easy as your friendship.
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 1),
        updatedAt: Date(timeIntervalSinceNow: -1_800),
        voiceAsset: VoiceAsset(
            audioFileReference: "sample_voice_wedding.m4a",
            voiceIdentifier: "warm_female_02",
            voiceDisplayName: "Sofia",
            duration: 38.0,
            createdAt: Date(timeIntervalSinceNow: -3_600 * 3)
        ),
        videoAsset: VideoAsset(
            videoFileReference: "sample_video_wedding.mp4",
            thumbnailReference: "sample_video_wedding_thumb.jpg",
            duration: 38.0,
            createdAt: Date(timeIntervalSinceNow: -1_800)
        )
    )

    public static let all: [Wish] = [
        videoWeddingWish,
        voiceBirthdayWish,
        textOnlyBirthdayWish
    ]
}
