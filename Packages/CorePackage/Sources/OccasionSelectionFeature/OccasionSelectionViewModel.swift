import Domain
import Localizations
import Observation

@MainActor
@Observable
final class OccasionSelectionViewModel {
	let occasions: [Occasion] = [
		Occasion(iconName: "birthday.cake", title: L10n.occasionBirthdayTitle, subtitle: L10n.occasionBirthdaySubtitle),
		Occasion(iconName: "heart.circle", title: L10n.occasionAnniversaryTitle, subtitle: L10n.occasionAnniversarySubtitle),
		Occasion(iconName: "gift.fill", title: L10n.occasionNameDayTitle, subtitle: L10n.occasionNameDaySubtitle),
		Occasion(iconName: "heart.fill", title: L10n.occasionWeddingTitle, subtitle: L10n.occasionWeddingSubtitle),
		Occasion(iconName: "camera.macro", title: L10n.occasionMothersDayTitle, subtitle: L10n.occasionMothersDaySubtitle),
		Occasion(iconName: "mustache", title: L10n.occasionFathersDayTitle, subtitle: L10n.occasionFathersDaySubtitle),
		Occasion(iconName: "leaf.fill", title: L10n.occasionWomensDayTitle, subtitle: L10n.occasionWomensDaySubtitle),
		Occasion(iconName: "trophy.fill", title: L10n.occasionCongratulationsTitle, subtitle: L10n.occasionCongratulationsSubtitle),
		Occasion(iconName: "hand.raised.fill", title: L10n.occasionApologyTitle, subtitle: L10n.occasionApologySubtitle),
		Occasion(iconName: "hands.clap.fill", title: L10n.occasionThanksTitle, subtitle: L10n.occasionThanksSubtitle),
		Occasion(iconName: "sparkles", title: L10n.occasionOtherTitle, subtitle: L10n.occasionOtherSubtitle)
	]

	var navigateToCreator = false

	func didSelectOccasion(_ occasion: Occasion) {
		navigateToCreator = true
	}
}
