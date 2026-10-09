import AVFoundation
import Dependencies
import Foundation

#if canImport(UIKit)
import UIKit
#endif

public struct VideoGenerationRequest: Sendable {
    public let text: String
    public let occasionKind: OccasionKind?

    /// Needed only to synthesize fresh speech — `nil` whenever `existingAudio` is set,
    /// since reusing an already-generated recording performs no new text-to-speech call.
    public let voiceGender: VoiceGender?
    public let providerVoiceID: String?

    /// An already-generated VoiceAsset's audio data, reused verbatim instead of
    /// synthesizing new speech — keeps the original voice/intonation/pace and avoids a
    /// redundant ElevenLabs call. `nil` triggers the normal text-to-speech generation.
    public let existingAudio: ExistingAudio?

    public init(
        text: String,
        occasionKind: OccasionKind? = nil,
        voiceGender: VoiceGender? = nil,
        providerVoiceID: String? = nil,
        existingAudio: ExistingAudio? = nil
    ) {
        self.text = text
        self.occasionKind = occasionKind
        self.voiceGender = voiceGender
        self.providerVoiceID = providerVoiceID
        self.existingAudio = existingAudio
    }

    public struct ExistingAudio: Sendable {
        public let data: Data
        public let fileExtension: String

        public init(data: Data, fileExtension: String) {
            self.data = data
            self.fileExtension = fileExtension
        }
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

    public func generateVideo(for request: VideoGenerationRequest) async throws -> VideoAsset {
        let dto = GenerateVideoRequestDTO(
            text: request.text,
            language: SupportedLanguage.current.rawValue,
            voiceGender: request.voiceGender.map { $0 == .male ? "male" : "female" },
            voiceId: request.providerVoiceID,
            occasionKind: request.occasionKind?.rawValue,
            existingAudioBase64: request.existingAudio?.data.base64EncodedString(),
            existingAudioFormat: request.existingAudio?.fileExtension
        )

        let videoData = try await apiClient.postRawData("/api/generateVideo", body: dto)
        let fileReference = "video_\(UUID().uuidString).mp4"
        try saveVideoFile(videoData, named: fileReference)

        let duration = try await videoDuration(forFileNamed: fileReference)
        let thumbnailReference = try? saveThumbnail(forFileNamed: fileReference)

        return VideoAsset(
            videoFileReference: fileReference,
            thumbnailReference: thumbnailReference,
            duration: duration
        )
    }

    private func documentsDirectory() throws -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw APIError.invalidResponse
        }

        return url
    }

    private func saveVideoFile(_ data: Data, named fileName: String) throws {
        let fileURL = try documentsDirectory().appendingPathComponent(fileName)
        try data.write(to: fileURL)
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
