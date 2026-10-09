import Foundation

struct GenerateVideoRequestDTO: Encodable {
    let text: String
    let language: String
    let voiceGender: String?
    let voiceId: String?
    let occasionKind: String?

    /// When set, the backend must reuse this audio verbatim instead of calling
    /// ElevenLabs again — see VideoGenerationRequest.existingAudio.
    let existingAudioBase64: String?
    let existingAudioFormat: String?
}
