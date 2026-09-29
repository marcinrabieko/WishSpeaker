import Localizations

public enum WishStyle: CaseIterable {
	case classic
	case touching
	case funny
	case short
	case poetic
	case religic

	var title: String {
		switch self {
		case .classic:
			L10n.formStyleClassic
		case .touching:
			L10n.formStyleTouching
		case .funny:
			L10n.formStyleFunny
		case .short:
			L10n.formStyleShort
		case .poetic:
			L10n.formStylePoetic
		case .religic:
			L10n.formStyleReligious
		}
	}
}
