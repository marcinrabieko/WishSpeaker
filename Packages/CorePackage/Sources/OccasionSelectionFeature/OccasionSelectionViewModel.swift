import Dependencies
import Domain
import Observation

@MainActor
@Observable
final class OccasionSelectionViewModel {
	let occasions: [Occasion] = Occasion.all

	var navigateToCreator = false

	@ObservationIgnored
	@Dependency(\.wishCreationManager)
	private var creationManager: WishCreationManager

	func didSelectOccasion(_ occasion: Occasion) {
		creationManager.selectedOccasion = occasion
		creationManager.currentForm.occasion = occasion.title
		navigateToCreator = true
	}
}
