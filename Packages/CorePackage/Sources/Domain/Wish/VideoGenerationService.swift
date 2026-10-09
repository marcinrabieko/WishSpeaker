import AVFoundation
import Dependencies
import Foundation

#if canImport(UIKit)
import UIKit
#endif

public struct VideoGenerationRequest: Sendable {
    public let text: String
    public let voiceGender: VoiceGender
    public let providerVoiceID: String?
    public let occasionKind: OccasionKind?

    public init(
        text: String,
        voiceGender: VoiceGender,
        providerVoiceID: String? = nil,
        occasionKind: OccasionKind? = nil
    ) {
        self.text = text
        self.voiceGender = voiceGender
        self.providerVoiceID = providerVoiceID
        self.occasionKind = occasionKind
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
            voiceGender: request.voiceGender == .male ? "male" : "female",
            voiceId: request.providerVoiceID,
            occasionKind: request.occasionKind?.rawValue
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
