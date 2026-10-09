import AVFoundation
import Dependencies
import Foundation

public struct VoiceGenerationRequest: Sendable {
    public let text: String
    public let voiceGender: VoiceGender
    public let providerVoiceID: String?

    /// The chosen narrator's display name (e.g. "Mark - Casual, Relaxed and Light"),
    /// saved verbatim onto the resulting VoiceAsset — distinguishes between two voices
    /// of the same gender, unlike deriving a name from `voiceGender` alone.
    public let voiceDisplayName: String

    public init(text: String, voiceGender: VoiceGender, providerVoiceID: String? = nil, voiceDisplayName: String) {
        self.text = text
        self.voiceGender = voiceGender
        self.providerVoiceID = providerVoiceID
        self.voiceDisplayName = voiceDisplayName
    }
}

public protocol VoiceGenerationService: Sendable {
    /// Synthesizes `request.text` to speech, saves the audio locally, and returns a
    /// VoiceAsset referencing it. Never returns the raw audio bytes — see VoiceAsset's
    /// own doc comment on why only a local file reference is kept in memory.
    func generateVoice(for request: VoiceGenerationRequest) async throws -> VoiceAsset
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
            voiceGender: request.voiceGender == .male ? "male" : "female",
            voiceId: request.providerVoiceID
        )

        let response: GenerateAudioResponseDTO = try await apiClient.post("/api/generateAudio", body: dto)

        guard let audioData = Data(base64Encoded: response.audioBase64) else {
            throw APIError.invalidResponse
        }

        let fileReference = "voice_\(UUID().uuidString).mp3"
        try saveFile(audioData, named: fileReference)

        let wordTimestampsFileReference = "voice_\(UUID().uuidString)_timestamps.json"
        try saveWordTimestamps(response.wordTimestamps, named: wordTimestampsFileReference)

        let duration = try await audioDuration(forFileNamed: fileReference)

        return VoiceAsset(
            audioFileReference: fileReference,
            voiceIdentifier: request.providerVoiceID ?? (request.voiceGender == .male ? VoiceCatalog.maleVoiceIDs[0] : VoiceCatalog.femaleVoiceIDs[0]),
            voiceDisplayName: request.voiceDisplayName,
            duration: duration,
            wordTimestampsFileReference: wordTimestampsFileReference
        )
    }

    private func saveFile(_ data: Data, named fileName: String) throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw APIError.invalidResponse
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }

    private func saveWordTimestamps(_ timestamps: [WordTimingDTO], named fileName: String) throws {
        let wordTimings = timestamps.map { WordTiming(text: $0.text, startMs: $0.startMs, endMs: $0.endMs) }
        let data = try JSONEncoder().encode(wordTimings)
        try saveFile(data, named: fileName)
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
