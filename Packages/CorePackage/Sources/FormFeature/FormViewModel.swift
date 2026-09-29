import Dependencies
import Domain
import Localizations
import Observation

@MainActor
@Observable
public final class FormViewModel {
	var relationText = ""
	var detailsText = ""
	var navigateToPreview = false
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

		creationManager.generatedText = MockWishGenerator.shared.generateMockWish(form: creationManager.currentForm)
		navigateToPreview = true
	}
}
