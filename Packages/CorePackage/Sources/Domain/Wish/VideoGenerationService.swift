import AVFoundation
import Dependencies
import Foundation
import Localizations
import VideoRendering

#if canImport(UIKit)
import UIKit
#endif

public struct VideoGenerationRequest: Sendable {
    public let text: String
    public let occasionKind: OccasionKind?

    /// Needed only to synthesize fresh speech — `nil` whenever `existingVoice` is set,
    /// since reusing an already-generated recording performs no new text-to-speech call.
    public let voiceGender: VoiceGender?
    public let providerVoiceID: String?

    /// An already-generated voice recording (with its word timestamps) to narrate the
    /// video with, instead of synthesizing the text again — keeps the original
    /// voice/intonation/pace and skips a redundant ElevenLabs call. Ignored (falls
    /// back to fresh synthesis) when its audio or timestamps file is missing.
    public let existingVoice: VoiceAsset?

    public init(
        text: String,
        occasionKind: OccasionKind? = nil,
        voiceGender: VoiceGender? = nil,
        providerVoiceID: String? = nil,
        existingVoice: VoiceAsset? = nil
    ) {
        self.text = text
        self.occasionKind = occasionKind
        self.voiceGender = voiceGender
        self.providerVoiceID = providerVoiceID
        self.existingVoice = existingVoice
    }
}

public protocol VideoGenerationService: Sendable {
    /// Synthesizes `request.text` to a narrated greeting-card video, saves the video
    /// (and a first-frame thumbnail) locally, and returns a VideoAsset referencing
    /// both. Never returns the raw video bytes — same rationale as VoiceAsset.
    func generateVideo(for request: VideoGenerationRequest) async throws -> VideoAsset
}

public struct LiveVideoGenerationService: VideoGenerationService {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    /// The backend only synthesizes the narration (audio + word timestamps); the video
    /// itself is rendered on device by `WishVideoRenderer`.
    public func generateVideo(for request: VideoGenerationRequest) async throws -> VideoAsset {
        let narration = try await narration(for: request)
        defer {
            if narration.isTemporary {
                try? FileManager.default.removeItem(at: narration.audioURL)
            }
        }

        let fileReference = "video_\(UUID().uuidString).mp4"
        try await WishVideoRenderer.render(
            WishVideoRenderRequest(
                audioURL: narration.audioURL,
                words: narration.words.sanitizedWishText.map { VideoWordTiming(text: $0.text, startMs: $0.startMs, endMs: $0.endMs) },
                theme: VideoTheme(occasionKind: request.occasionKind),
                greeting: videoGreeting(for: request.occasionKind),
                outputURL: try documentsDirectory().appendingPathComponent(fileReference)
            )
        )

        let duration = try await videoDuration(forFileNamed: fileReference)
        let thumbnailReference = try? saveThumbnail(forFileNamed: fileReference)

        return VideoAsset(
            videoFileReference: fileReference,
            thumbnailReference: thumbnailReference,
            duration: duration
        )
    }

    private struct Narration {
        let audioURL: URL
        let words: [WordTiming]
        let isTemporary: Bool
    }

    private func narration(for request: VideoGenerationRequest) async throws -> Narration {
        if let existingVoice = request.existingVoice,
           let audioURL = existingVoice.audioURL,
           let words = existingVoice.wordTimestamps {
            return Narration(audioURL: audioURL, words: words, isTemporary: false)
        }

        let dto = GenerateAudioRequestDTO(
            text: request.text.sanitizedWishText,
            language: SupportedLanguage.current.rawValue,
            voiceGender: request.voiceGender == .male ? "male" : "female",
            voiceId: request.providerVoiceID
        )

        let response: GenerateAudioResponseDTO = try await apiClient.post("/api/wishspeaker/generateAudio", body: dto)

        guard let audioData = Data(base64Encoded: response.audioBase64) else {
            throw APIError.invalidResponse
        }

        let audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("narration_\(UUID().uuidString).mp3")
        try audioData.write(to: audioURL)

        return Narration(
            audioURL: audioURL,
            words: response.wordTimestamps.map { WordTiming(text: $0.text, startMs: $0.startMs, endMs: $0.endMs) },
            isTemporary: true
        )
    }

    private func documentsDirectory() throws -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw APIError.invalidResponse
        }

        return url
    }

    private func videoDuration(forFileNamed fileName: String) async throws -> TimeInterval {
        let fileURL = try documentsDirectory().appendingPathComponent(fileName)
        let asset = AVURLAsset(url: fileURL)
        let duration = try await asset.load(.duration)

        return duration.seconds
    }

    /// Extracts the video's first frame as a thumbnail image, saved as a separate JPEG
    /// file alongside the video — used by the library grid so scrubbing to frame 0 of
    /// every video isn't needed just to show a preview.
    private func saveThumbnail(forFileNamed videoFileName: String) throws -> String {
        let videoURL = try documentsDirectory().appendingPathComponent(videoFileName)
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)

        #if canImport(UIKit)
        let uiImage = UIImage(cgImage: cgImage)
        guard let jpegData = uiImage.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidResponse
        }
        #else
        throw APIError.invalidResponse
        #endif

        let thumbnailFileName = "thumb_\(UUID().uuidString).jpg"
        let thumbnailURL = try documentsDirectory().appendingPathComponent(thumbnailFileName)
        try jpegData.write(to: thumbnailURL)

        return thumbnailFileName
    }
}

/// Fixed per-occasion headline burned into the video card — never AI-generated or
/// derived from the wish text; no occasion falls back to the `.other` headline.
private func videoGreeting(for occasionKind: OccasionKind?) -> String {
    switch occasionKind {
    case .birthday:
        L10n.videoGreetingBirthday
    case .anniversary:
        L10n.videoGreetingAnniversary
    case .nameDay:
        L10n.videoGreetingNameDay
    case .wedding:
        L10n.videoGreetingWedding
    case .mothersDay:
        L10n.videoGreetingMothersDay
    case .fathersDay:
        L10n.videoGreetingFathersDay
    case .womensDay:
        L10n.videoGreetingWomensDay
    case .congratulations:
        L10n.videoGreetingCongratulations
    case .apology:
        L10n.videoGreetingApology
    case .thanks:
        L10n.videoGreetingThanks
    case .other, nil:
        L10n.videoGreetingOther
    }
}

private extension VideoTheme {
    /// Same occasion -> theme matrix as the backend's OCCASION_TO_THEME; anything not
    /// listed (including no occasion at all) falls back to `.classic`.
    init(occasionKind: OccasionKind?) {
        switch occasionKind {
        case .birthday, .congratulations, .fathersDay:
            self = .celebration
        case .anniversary:
            self = .romantic
        case .wedding:
            self = .wedding
        case .mothersDay, .womensDay, .nameDay:
            self = .floral
        case .apology, .thanks:
            self = .calm
        case .other, nil:
            self = .classic
        }
    }
}

private struct VideoGenerationServiceKey: DependencyKey {
    static var liveValue: any VideoGenerationService {
        @Dependency(\.apiEnvironment) var apiEnvironment
        return LiveVideoGenerationService(apiClient: APIClient(baseURL: apiEnvironment.baseURL))
    }
}

public extension DependencyValues {
    var videoGenerationService: any VideoGenerationService {
        get { self[VideoGenerationServiceKey.self] }
        set { self[VideoGenerationServiceKey.self] = newValue }
    }
}
