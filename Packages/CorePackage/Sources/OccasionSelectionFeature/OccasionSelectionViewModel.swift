import Dependencies
import Domain
import Observation
import SwiftUI

@MainActor
@Observable
final class OccasionSelectionViewModel {
	let occasions: [Occasion] = Occasion.all

	@ObservationIgnored
	@Dependency(\.wishCreationManager)
	private var creationManager: WishCreationManager

	func didSelectOccasion(_ occasion: Occasion, path: Binding<NavigationPath>) {
		creationManager.selectedOccasion = occasion
		creationManager.currentForm.occasion = occasion.title
		path.wrappedValue.append(CreateFlowRoute.form)
	}
}
