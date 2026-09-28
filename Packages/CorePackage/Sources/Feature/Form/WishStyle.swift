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
			"Klasyczne"
		case .touching:
			"Wzruszające"
		case .funny:
			"Zabawne"
		case .short:
			"Krótkie"
		case .poetic:
			"Poetyckie"
		case .religic:
			"Religijne"
		}
	}
}
