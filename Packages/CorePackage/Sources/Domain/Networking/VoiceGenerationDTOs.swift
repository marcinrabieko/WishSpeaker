import Foundation

struct GenerateAudioRequestDTO: Encodable {
    let text: String
    let language: String
    let voiceGender: String
    let voiceId: String?
}

struct VoiceMetadataResponseDTO: Decodable {
    let voiceId: String
    let name: String
    let description: String?
    let labels: [String: String]
    let previewUrl: String?
    let verifiedLanguages: [VerifiedLanguageDTO]
}

struct VerifiedLanguageDTO: Decodable {
    let language: String
    let locale: String?
    let previewUrl: String?
}
