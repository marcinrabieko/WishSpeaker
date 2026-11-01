import Foundation

/// Three curated demo wishes shown on the Example Wishes screen, one per media type —
/// video, voice, and text-only — in that order, each demonstrating a different
/// occasion/variant combination. None of the audio/video files point at recordings that
/// exist yet (see VoiceAsset+AudioURL), so the player
/// gracefully shows a disabled state until real samples are bundled.
public enum ExampleData {
    public static let exampleWishes: [Wish] = [
        Wish(
            occasionKind: .wedding,
            occasionTitle: "Wedding",
            recipient: "Alicia & Daniel",
            variant: .natural,
            text: """
            Alicia and Daniel, congratulations on your wedding day. May your marriage be \
            built on the same trust and laughter that brought you here, and may every year \
            together feel as easy as this one. Wishing you a lifetime of happiness.
            """,
            videoAsset: VideoAsset(
                videoFileReference: "example_alicia_daniel_wedding_natural_en.mp4",
                duration: 41.0
            )
        ),
        Wish(
            occasionKind: .birthday,
            occasionTitle: "Birthday",
            recipient: "Gregory",
            variant: .warm,
            text: """
            Gregory, on your birthday I wish you that everything in life aligns as \
            perfectly as the paving stones you lay every day. May your business grow, your \
            projects succeed and your dream of owning a quad finally become reality. All the \
            best from Marcin.
            """,
            voiceAsset: VoiceAsset(
                audioFileReference: "example_gregory_birthday_warm_en.m4a",
                voiceIdentifier: "warm_male_01",
                voiceDisplayName: "James",
                duration: 34.0
            )
        ),
        Wish(
            occasionKind: .birthday,
            occasionTitle: "Birthday",
            recipient: "Noah",
            variant: .light,
            text: """
            Noah, happy birthday! Officially aged up, no refunds. Hope today is full of \
            the good stuff — snacks, laughs, and minimal responsibility. Enjoy the extra \
            candle!
            """
        )
    ]
}
