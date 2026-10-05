import AVFoundation
import Dependencies
import Foundation

public struct VoiceGenerationRequest: Sendable {
    public let text: String
    public let voiceGender: VoiceGender

    public init(text: String, voiceGender: VoiceGender) {
        self.text = text
        self.voiceGender = voiceGender
    }
}

public protocol VoiceGenerationService: Sendable {
    /// Synthesizes `request.text` to speech, saves the audio locally, and returns a
    /// VoiceAsset referencing it. Never returns the raw audio bytes — see VoiceAsset's
    /// own doc comment on why only a local file reference is kept in memory.
    func generateVoice(for request: VoiceGenerationRequest) async throws -> VoiceAsset
}

public struct MockVoiceGenerationService: VoiceGenerationService {
    public init() {}

    public func generateVoice(for request: VoiceGenerationRequest) async throws -> VoiceAsset {
        try await Task.sleep(nanoseconds: 1_200_000_000)

        return VoiceAsset(
            audioFileReference: "mock_voice.m4a",
            voiceIdentifier: request.voiceGender == .male ? "warm_male_01" : "warm_female_01",
            voiceDisplayName: request.voiceGender == .male ? "James" : "Sofia",
            duration: 24.0
        )
    }
}

public struct LiveVoiceGenerationService: VoiceGenerationService {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func generateVoice(for request: VoiceGenerationRequest) async throws -> VoiceAsset {
        let dto = GenerateAudioRequestDTO(
            text: request.text,
            language: SupportedLanguage.current.rawValue,
            voiceGender: request.voiceGender == .male ? "male" : "female"
        )

        let audioData = try await apiClient.postRawData("/api/generateAudio", body: dto)
        let fileReference = "voice_\(UUID().uuidString).mp3"
        try saveAudioFile(audioData, named: fileReference)

        let duration = try await audioDuration(forFileNamed: fileReference)

        return VoiceAsset(
            audioFileReference: fileReference,
            voiceIdentifier: request.voiceGender == .male ? "warm_male_01" : "warm_female_01",
            voiceDisplayName: request.voiceGender == .male ? "James" : "Sofia",
            duration: duration
        )
    }

    private func saveAudioFile(_ data: Data, named fileName: String) throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw APIError.invalidResponse
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }

    private func audioDuration(forFileNamed fileName: String) async throws -> TimeInterval {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return 0
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        let asset = AVURLAsset(url: fileURL)
        let duration = try await asset.load(.duration)

        return duration.seconds
    }
}

private struct VoiceGenerationServiceKey: DependencyKey {
    static var liveValue: any VoiceGenerationService {
        @Dependency(\.apiEnvironment) var apiEnvironment
        return LiveVoiceGenerationService(apiClient: APIClient(baseURL: apiEnvironment.baseURL))
    }
}

public extension DependencyValues {
    var voiceGenerationService: any VoiceGenerationService {
        get { self[VoiceGenerationServiceKey.self] }
        set { self[VoiceGenerationServiceKey.self] = newValue }
    }
}
