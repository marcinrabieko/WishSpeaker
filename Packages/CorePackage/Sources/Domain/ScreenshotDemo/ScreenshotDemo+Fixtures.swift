#if DEBUG
import Dependencies
import Foundation

/// The scripted content the screenshot walkthrough types and "generates". The media
/// files referenced here live in StoreAssets/Fixtures and are copied into the app's
/// Documents directory by StoreAssets/capture.py before every run.
public extension ScreenshotDemo {
    static let occasionKind: OccasionKind = .birthday

    static let recipientText = "Mia, my best friend"

    static let detailsText = "Turning 30! Ran her first marathon this year, moved to Lisbon and adopted a rescue dog called Pickle."

    static let generatedWishes = WishGenerationResult(
        warm: """
        Happy 30th birthday, Mia! What a year it's been. You crossed the finish line of your \
        very first marathon, packed up your whole life and made Lisbon your home, and gave \
        Pickle the luckiest second chance a rescue dog could ask for. Watching you chase big \
        things with that fearless smile never gets old. I hope thirty brings you sunny mornings \
        by the river, long runs that feel easy, and plenty of time to celebrate how far you've \
        come. I'm so proud to call you my best friend. Happy birthday!
        """,
        natural: """
        Happy birthday, Mia! Thirty looks good on you. A first marathon, a brand-new life in \
        Lisbon and a rescue dog who clearly thinks you hung the moon — not a bad way to wrap up \
        your twenties. Here's to a year of new running routes, great coffee and many more \
        adventures together.
        """,
        light: """
        Happy 30th, Mia! This year you ran 42 kilometres on purpose, moved to a city made \
        entirely of hills and adopted a dog named Pickle. Clearly nothing scares you — not even \
        turning thirty. Have the best birthday, and give Pickle an extra treat from me!
        """
    )

    /// Set on the draft right before leaving the Wishes screen, so the result screen
    /// opens straight on the finished video instead of the Voice/Video generation flow.
    static func attachVideo() {
        @Dependency(\.wishCreationManager) var creationManager: WishCreationManager

        creationManager.generatedVideoAsset = VideoAsset(
            videoFileReference: Fixture.videoFileName,
            thumbnailReference: Fixture.thumbnailFileName,
            duration: Fixture.videoDuration
        )
    }

    /// Saves the finished draft the way VideoViewModel does once a real video is
    /// generated — the walkthrough skips that screen, so without this the Library
    /// screenshot would be missing its own Wish.
    static func saveWalkthroughWish() {
        @Dependency(\.wishCreationManager) var creationManager: WishCreationManager
        @Dependency(\.wishLibraryManager) var libraryManager: WishLibraryManager

        libraryManager.save(creationManager.finalizeWish())
    }

    /// Older entries placed under the walkthrough's own Wish, so the Library screenshot
    /// shows every media type instead of a single row.
    static func seedLibrary() {
        @Dependency(\.wishLibraryManager) var libraryManager: WishLibraryManager

        let day: TimeInterval = 24.0 * 60.0 * 60.0

        libraryManager.save(
            Wish(
                occasionKind: .thanks,
                occasionTitle: "Thank You",
                recipient: "Sarah",
                variant: .warm,
                text: """
                Hey Sarah, I've been meaning to tell you something. Thank you. Not just for the \
                things you've done, but for the way you've always been there.
                """,
                createdAt: Date().addingTimeInterval(-3.0 * day),
                updatedAt: Date().addingTimeInterval(-3.0 * day),
                voiceAsset: VoiceAsset(
                    audioFileReference: Fixture.voiceFileName,
                    voiceIdentifier: "GzE4TcXfh9rYCU9gVgPp",
                    voiceDisplayName: "Alex Wright",
                    duration: 31.3
                )
            )
        )

        libraryManager.save(
            Wish(
                occasionKind: .anniversary,
                occasionTitle: "Anniversary",
                recipient: "Mom & Dad",
                variant: .natural,
                text: """
                Mom and Dad, happy 35th anniversary! Thirty-five years of Sunday pancakes, road \
                trips with terrible playlists and holding hands like it's still your first date. \
                Thank you for showing us what real love looks like.
                """,
                createdAt: Date().addingTimeInterval(-9.0 * day),
                updatedAt: Date().addingTimeInterval(-9.0 * day)
            )
        )
    }

    /// Renders the warm wish into the narrated fixture video through the real backend
    /// and on-device renderer, then renames the output to the fixed names the
    /// walkthrough expects. Run once via `capture.py --prepare` whenever the wish
    /// text changes — the result gets copied out into StoreAssets/Fixtures.
    static func prepareFixtures() async {
        @Dependency(\.videoGenerationService) var videoGenerationService: any VideoGenerationService

        do {
            let videoAsset = try await videoGenerationService.generateVideo(
                for: VideoGenerationRequest(
                    text: generatedWishes.warm,
                    occasionKind: occasionKind,
                    voiceGender: .female,
                    providerVoiceID: VoiceCatalog.femaleVoiceIDs[0]
                )
            )

            try moveDocument(videoAsset.videoFileReference, to: Fixture.videoFileName)

            if let thumbnailReference = videoAsset.thumbnailReference {
                try moveDocument(thumbnailReference, to: Fixture.thumbnailFileName)
            }

            mark("prepared", contents: "\(videoAsset.duration)")
        } catch {
            mark("prepare-failed", contents: "\(error)")
        }
    }

    private static func moveDocument(_ fileName: String, to newFileName: String) throws {
        let destinationURL = URL.documentsDirectory.appending(path: newFileName)

        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: URL.documentsDirectory.appending(path: fileName), to: destinationURL)
    }
}

private enum Fixture {
    static let videoFileName = "screenshot_demo.mp4"
    static let thumbnailFileName = "screenshot_demo_thumbnail.jpg"
    static let voiceFileName = "screenshot_demo_voice.mp3"
    static let videoDuration: TimeInterval = 37.93
}

/// Returns the scripted wishes instantly, so the walkthrough skips the generation
/// loader entirely.
public struct ScreenshotDemoWishGenerationService: WishGenerationService {
    public init() {}

    public func generateWishes(for request: WishGenerationRequest) async throws -> WishGenerationResult {
        await ScreenshotDemo.generatedWishes
    }

    public func regenerateWish(
        for request: WishGenerationRequest,
        variant: WishVariant,
        previousText: String
    ) async throws -> String {
        previousText
    }
}
#endif
