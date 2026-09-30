import Dependencies
import Domain
import Observation

@MainActor
@Observable
public final class LibraryViewModel {
    var savedWishes: [Wish] = []

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    public init() {}

    func didAppear() {
        savedWishes = libraryManager.savedWishes
    }
}
