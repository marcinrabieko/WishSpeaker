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
