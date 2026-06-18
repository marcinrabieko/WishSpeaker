import UIKit

struct Occasion: Identifiable, Hashable {
	let id = UUID()
	let iconName: String
	let title: String
	let subtitle: String
}
