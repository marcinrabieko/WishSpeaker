import Foundation

struct GenerateAudioRequestDTO: Encodable {
    let text: String
    let language: String
    let voiceGender: String
}
