import Localizations

public enum WishVariant: String, CaseIterable, Hashable, Sendable {
    case warm
    case natural
    case light

    public var displayName: String {
        switch self {
        case .warm:
            L10n.wishVariantWarm

        case .natural:
            L10n.wishVariantNatural

        case .light:
            L10n.wishVariantLight
        }
    }

    public var iconName: String {
        switch self {
        case .warm:
            "heart.fill"

        case .natural:
            "leaf.fill"

        case .light:
            "sparkles"
        }
    }
}
