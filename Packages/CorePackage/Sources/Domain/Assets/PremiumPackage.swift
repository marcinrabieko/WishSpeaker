import Foundation

public struct PremiumPackage: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let price: Double
    public let recommended: Bool

    public init(id: UUID = UUID(), name: String, description: String, price: Double, recommended: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.recommended = recommended
    }
}
