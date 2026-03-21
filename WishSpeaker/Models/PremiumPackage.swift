import Foundation

struct PremiumPackage: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let recommended: Bool

    init(id: UUID = UUID(), name: String, description: String, price: Double, recommended: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.recommended = recommended
    }
}
