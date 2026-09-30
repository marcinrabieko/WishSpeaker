import Dependencies
import Foundation

/// Holds the persistent library of wishes the user has already created.
///
/// One Wish = one Library row. A Wish can evolve over time — text only, then
/// text + voice, then text + voice + video — so saving a Wish with an id that
/// already exists replaces that row in place rather than appending a duplicate.
@MainActor
public final class WishLibraryManager {
    public var savedWishes: [Wish] = []

    public init() {}

    public func save(_ wish: Wish) {
        if let index = savedWishes.firstIndex(where: { $0.id == wish.id }) {
            savedWishes[index] = wish
        } else {
            savedWishes.insert(wish, at: 0)
        }
    }
}

struct WishLibraryManagerKey: DependencyKey {
    static var liveValue: WishLibraryManager {
        @MainActor get { WishLibraryManager() }
    }
}

public extension DependencyValues {
    var wishLibraryManager: WishLibraryManager {
        get { self[WishLibraryManagerKey.self] }
        set { self[WishLibraryManagerKey.self] = newValue }
    }
}
