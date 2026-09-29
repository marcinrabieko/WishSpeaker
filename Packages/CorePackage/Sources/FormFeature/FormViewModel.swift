import Dependencies
import Domain
import Localizations
import Observation

@MainActor
@Observable
public final class FormViewModel {
	var relationText = ""
	var detailsText = ""
	var navigateToWishes = false
	var selectedOccasion: Occasion?

	var recipientTitle: String {
		selectedOccasion?.formCopy.recipientTitle ?? L10n.formRecipientQuestion
	}

	var recipientPlaceholder: String {
		selectedOccasion?.formCopy.recipientPlaceholder ?? L10n.formRecipientPlaceholder
	}

	var detailsPlaceholder: String {
		selectedOccasion?.formCopy.detailsPlaceholder ?? L10n.formDetailsPlaceholder
	}

	@ObservationIgnored
	@Dependency(\.wishCreationManager)
	private var creationManager: WishCreationManager

	public init() {}

	func didAppear() {
		selectedOccasion = creationManager.selectedOccasion
	}

	func didTapGenerate() {
		creationManager.currentForm.relation = relationText
		creationManager.currentForm.note = detailsText

		// Clear stale candidates so WishesView always regenerates for this submission.
		creationManager.generatedWishes = nil
		creationManager.selectedVariant = nil

		navigateToWishes = true
	}
}
