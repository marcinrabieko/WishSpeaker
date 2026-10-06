import Dependencies
import Domain
import Localizations
import Observation
import SwiftUI

@MainActor
@Observable
public final class FormViewModel {
	var relationText = ""
	var detailsText = ""
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

	var isGenerateEnabled: Bool {
		!relationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	@ObservationIgnored
	@Dependency(\.wishCreationManager)
	private var creationManager: WishCreationManager

	public init() {}

	func didAppear() {
		selectedOccasion = creationManager.selectedOccasion
		relationText = creationManager.currentForm.relation
		detailsText = creationManager.currentForm.note
	}

	func didTapGenerate(path: Binding<NavigationPath>) {
		guard isGenerateEnabled else {
			return
		}

		creationManager.currentForm.relation = relationText.trimmingCharacters(in: .whitespacesAndNewlines)
		creationManager.currentForm.note = detailsText

		// Clear stale candidates so WishesView always regenerates for this submission.
		creationManager.generatedWishes = nil
		creationManager.selectedVariant = nil

		path.wrappedValue.append(CreateFlowRoute.wishes)
	}
}
