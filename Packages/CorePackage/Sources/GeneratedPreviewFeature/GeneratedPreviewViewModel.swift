import Dependencies
import Domain
import Observation

@MainActor
@Observable
public final class GeneratedPreviewViewModel {
	var navigateToPackages = false
	var generatedText = ""

	@ObservationIgnored
	@Dependency(\.wishCreationManager)
	private var creationManager: WishCreationManager

	public init() {}

	func didAppear() {
		generatedText = creationManager.generatedText
	}

	func didTapGenerateAgain() {
		let text = MockWishGenerator.shared.generateMockWish(form: creationManager.currentForm)
		creationManager.generatedText = text
		generatedText = text
	}

	func didTapContinue() {
		navigateToPackages = true
	}
}
