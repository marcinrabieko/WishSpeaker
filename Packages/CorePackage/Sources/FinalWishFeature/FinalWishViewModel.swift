import Dependencies
import Domain
import Observation

@MainActor
@Observable
public final class FinalWishViewModel {
    var wish: Wish?
    var selectedPackage: PremiumPackage?

    private var hasBeenSaved = false

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    public init() {}

    func didAppear() {
        guard !hasBeenSaved else {
            return
        }
        hasBeenSaved = true

        let finalizedWish = creationManager.finalizeWish()
        wish = finalizedWish
        selectedPackage = finalizedWish.selectedPackage

        libraryManager.save(finalizedWish)
    }
}
