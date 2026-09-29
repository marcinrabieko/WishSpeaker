import Dependencies
import Domain
import Observation

@MainActor
@Observable
public final class MyWishesViewModel {
    var savedWishes: [Wish] = []

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    public init() {}

    func didAppear() {
        savedWishes = libraryManager.savedWishes
    }
}
