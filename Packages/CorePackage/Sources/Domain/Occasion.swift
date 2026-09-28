import Foundation

public struct Occasion: Identifiable, Hashable, Sendable {
	public let id = UUID()
	public let iconName: String
	public let title: String
	public let subtitle: String

	public init(iconName: String, title: String, subtitle: String) {
		self.iconName = iconName
		self.title = title
		self.subtitle = subtitle
	}
}
