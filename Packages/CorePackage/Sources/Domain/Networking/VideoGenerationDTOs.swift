import Foundation

struct GenerateVideoRequestDTO: Encodable {
    let text: String
    let language: String
    let voiceGender: String
    let voiceId: String?
    let occasionKind: String?
}
