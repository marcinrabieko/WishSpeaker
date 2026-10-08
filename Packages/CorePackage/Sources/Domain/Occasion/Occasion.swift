import Foundation

public enum OccasionKind: String, CaseIterable, Hashable, Sendable {
	case birthday
	case anniversary
	case nameDay
	case wedding
	case mothersDay
	case fathersDay
	case womensDay
	case congratulations
	case apology
	case thanks
	case other

	/// The occasion_kind string the backend's video theme matrix expects (see
	/// WishSpeaker-Backend's OCCASION_TO_THEME). Not a plain `rawValue`/snake_case
	/// conversion — `.thanks` maps to the backend's literal "thank_you" (a different
	/// word, not just a different casing), and `.fathersDay`/`.other` have no
	/// dedicated theme in the 6-theme matrix (celebration/romantic/wedding/floral/
	/// calm/classic), so they intentionally fall back to "celebration"/nil to land on
	/// the backend's own classic-theme default.
	public var backendOccasionKey: String? {
		switch self {
		case .birthday:
			"birthday"
		case .anniversary:
			"anniversary"
		case .nameDay:
			"name_day"
		case .wedding:
			"wedding"
		case .mothersDay:
			"mothers_day"
		case .fathersDay:
			"birthday" // no dedicated theme — reuses celebration via the same backend key
		case .womensDay:
			"womens_day"
		case .congratulations:
			"congratulations"
		case .apology:
			"apology"
		case .thanks:
			"thank_you"
		case .other:
			nil
		}
	}
}

public struct Occasion: Identifiable, Hashable, Sendable {
	public let id = UUID()
	public let kind: OccasionKind
	public let iconName: String
	public let title: String
	public let subtitle: String

	public init(kind: OccasionKind, iconName: String, title: String, subtitle: String) {
		self.kind = kind
		self.iconName = iconName
		self.title = title
		self.subtitle = subtitle
	}
}
