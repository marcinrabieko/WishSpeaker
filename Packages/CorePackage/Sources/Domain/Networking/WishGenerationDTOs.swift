import Foundation

struct GenerateWishesRequestDTO: Encodable {
    let recipientName: String
    let occasionKind: String
    let context: String?
    let language: String
}

struct WishVariantsDTO: Decodable {
    let greeting: String
    let warm: String
    let natural: String
    let light: String
}

struct RegenerateWishRequestDTO: Encodable {
    let recipientName: String
    let occasionKind: String
    let variant: String
    let previousText: String
    let context: String?
    let language: String
}

struct RegenerateWishResponseDTO: Decodable {
    let text: String
}
