import Foundation

public struct WishGenerationResult: Sendable {
    public var greeting: String
    public var warm: String
    public var natural: String
    public var light: String

    public init(greeting: String, warm: String, natural: String, light: String) {
        self.greeting = greeting
        self.warm = warm
        self.natural = natural
        self.light = light
    }

    public func text(for variant: WishVariant) -> String {
        switch variant {
        case .warm:
            warm

        case .natural:
            natural

        case .light:
            light
        }
    }

    public mutating func setText(_ text: String, for variant: WishVariant) {
        switch variant {
        case .warm:
            warm = text

        case .natural:
            natural = text

        case .light:
            light = text
        }
    }
}
