import Foundation

struct GenerateVideoRequestDTO: Encodable {
    let text: String
    let language: String
    let voiceGender: String?
    let voiceId: String?
    let occasionKind: String?

    /// When both set, the backend reuses this audio (and its already-known word
    /// timestamps) verbatim instead of calling ElevenLabs again — see
    /// VideoGenerationRequest.existingAudio. The backend decodes straight to bytes, so
    /// no filename/format field is needed here.
    let existingAudioBase64: String?
    let existingWordTimestamps: [WordTimingDTO]?
}
