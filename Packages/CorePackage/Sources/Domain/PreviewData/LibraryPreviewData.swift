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

    public static let textOnlyAnniversaryWish = Wish(
        occasionKind: .anniversary,
        occasionTitle: "Anniversary",
        recipient: "Grandma & Grandpa",
        context: "celebrating 50 years together",
        variant: .warm,
        text: """
        Fifty years together is a true testament to the kind of love that only grows \
        stronger with time. Thank you for showing all of us what commitment and \
        tenderness really look like. Happy anniversary!
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 8),
        updatedAt: Date(timeIntervalSinceNow: -86_400 * 8)
    )

    public static let voiceNameDayWish = Wish(
        occasionKind: .nameDay,
        occasionTitle: "Name Day",
        recipient: "Agnieszka",
        context: "always the first to help out at work",
        variant: .natural,
        text: """
        Agnieszka, wishing you a wonderful name day! Thank you for always being the \
        person everyone can count on. May today bring you as much warmth as you give \
        to everyone around you.
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 3),
        updatedAt: Date(timeIntervalSinceNow: -3_600 * 20),
        voiceAsset: VoiceAsset(
            audioFileReference: "sample_voice_agnieszka_nameday.m4a",
            voiceIdentifier: "light_female_01",
            voiceDisplayName: "Zofia",
            duration: 29.0,
            createdAt: Date(timeIntervalSinceNow: -3_600 * 20)
        )
    )

    public static let textOnlyThanksWish = Wish(
        occasionKind: .thanks,
        occasionTitle: "Thank You",
        recipient: "Tomasz",
        context: "helped move apartments over the whole weekend",
        variant: .light,
        text: """
        Tomasz, I genuinely don't know how I would have survived moving weekend \
        without you. Thank you for the boxes, the jokes, and for not complaining \
        once about the stairs. You're the best.
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 12),
        updatedAt: Date(timeIntervalSinceNow: -86_400 * 12)
    )

    public static let videoCongratulationsWish = Wish(
        occasionKind: .congratulations,
        occasionTitle: "Congratulations",
        recipient: "Kasia",
        context: "just passed her bar exam after years of studying",
        variant: .warm,
        text: """
        Kasia, congratulations on passing the bar exam! Years of hard work, late \
        nights and sacrifice have finally paid off. We always knew you had it in \
        you — welcome to the next chapter of your career.
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 4),
        updatedAt: Date(timeIntervalSinceNow: -3_600 * 2),
        voiceAsset: VoiceAsset(
            audioFileReference: "sample_voice_kasia_congrats.m4a",
            voiceIdentifier: "warm_male_01",
            voiceDisplayName: "James",
            duration: 35.0,
            createdAt: Date(timeIntervalSinceNow: -3_600 * 3)
        ),
        videoAsset: VideoAsset(
            videoFileReference: "sample_video_kasia_congrats.mp4",
            thumbnailReference: "sample_video_kasia_congrats_thumb.jpg",
            duration: 35.0,
            createdAt: Date(timeIntervalSinceNow: -3_600 * 2)
        )
    )

    public static let textOnlyApologyWish = Wish(
        occasionKind: .apology,
        occasionTitle: "Apology",
        recipient: "Marta",
        context: "forgot her birthday last month",
        variant: .natural,
        text: """
        Marta, I'm really sorry for missing your birthday last month — you deserved \
        better than that. Please know how much your friendship means to me, and \
        let's celebrate properly soon, I promise.
        """,
        createdAt: Date(timeIntervalSinceNow: -86_400 * 6),
        updatedAt: Date(timeIntervalSinceNow: -86_400 * 6)
    )

    public static let all: [Wish] = [
        videoWeddingWish,
        videoCongratulationsWish,
        voiceNameDayWish,
        voiceBirthdayWish,
        textOnlyApologyWish,
        textOnlyAnniversaryWish,
        textOnlyThanksWish,
        textOnlyBirthdayWish
    ]
}
