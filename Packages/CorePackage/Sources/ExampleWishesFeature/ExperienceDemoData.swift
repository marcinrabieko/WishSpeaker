import Domain
import Foundation

/// The exactly-two curated demo materials shown on the "Hear an example" screen — a
/// real, finished Birthday video and Thank You voice message generated once through
/// the WishSpeaker backend, bundled as static files (never regenerated, never saved
/// as a Library Wish) rather than downloaded or produced on demand.
///
/// Modeled as ordinary `Wish` values — each with a `bundledVideoURL`/`bundledAudioURL`
/// VideoAsset/VoiceAsset pointing into this feature's own resource bundle instead of
/// Documents — purely so the existing WishLibraryCard/ExampleWishDetailView/
/// InlineVoicePlayer/LibraryVideoThumbnail components can render them unmodified.
public enum ExperienceDemoData {
    public static let birthdayVideo = Wish(
        occasionKind: .birthday,
        occasionTitle: "Birthday",
        recipient: "Emma",
        variant: .warm,
        text: """
        Happy Birthday, Emma!

        You know what makes you special?

        It's not just the big things. It's the way you remember the little details, make \
        ordinary days feel brighter, and somehow always know when someone needs a smile.

        I hope this year gives you back even a little of the happiness you bring to \
        everyone around you.

        More unexpected adventures, more moments that make you laugh until your cheeks \
        hurt, and more reasons to feel proud of the person you're becoming.

        You deserve all of it.

        Happy Birthday!
        """,
        videoAsset: VideoAsset(
            videoFileReference: "birthday_demo.mp4",
            duration: 35.9,
            bundledVideoURL: Bundle.module.url(forResource: "birthday_demo", withExtension: "mp4"),
            bundledThumbnailURL: Bundle.module.url(forResource: "birthday_demo_thumbnail", withExtension: "jpg")
        )
    )

    public static let thankYouAudio = Wish(
        occasionKind: .thanks,
        occasionTitle: "Thank You",
        recipient: "Sarah",
        variant: .warm,
        text: """
        Hey Sarah,

        I've been meaning to tell you something.

        Thank you.

        Not just for the things you've done, but for the way you've always been there.

        For listening when I needed to talk.
        For making me laugh when everything felt a little too much.
        And for showing up, even when I didn't know how to ask.

        I don't think I say it enough, but having you in my life makes a bigger \
        difference than you probably realize.

        So... thank you. Really.
        """,
        voiceAsset: VoiceAsset(
            audioFileReference: "thankyou_demo.mp3",
            voiceIdentifier: "GzE4TcXfh9rYCU9gVgPp",
            voiceDisplayName: "Alex Wright",
            duration: 31.3,
            bundledAudioURL: Bundle.module.url(forResource: "thankyou_demo", withExtension: "mp3")
        )
    )

    public static let wishes: [Wish] = [birthdayVideo, thankYouAudio]
}
