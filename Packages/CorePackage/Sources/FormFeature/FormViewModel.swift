import Dependencies
import Domain
import Observation

@MainActor
@Observable
public final class FormViewModel {
	var relationText = ""
	var detailsText = ""
	var selectedStyle: WishStyle = .classic
	var navigateToPreview = false

	@ObservationIgnored
	@Dependency(\.wishCreationManager)
	private var creationManager: WishCreationManager

	public init() {}

	func didSelectStyle(_ style: WishStyle) {
		selectedStyle = style
	}

	func didTapGenerate() {
		creationManager.currentForm.relation = relationText
		creationManager.currentForm.note = detailsText
		creationManager.currentForm.tone = selectedStyle.title

		creationManager.generatedText = MockWishGenerator.shared.generateMockWish(form: creationManager.currentForm)
		navigateToPreview = true
	}
}
