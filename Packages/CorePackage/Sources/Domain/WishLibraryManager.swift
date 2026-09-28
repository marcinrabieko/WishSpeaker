import Dependencies
import Foundation

/// Holds the persistent library of wishes the user has already created.
@MainActor
public final class WishLibraryManager {
    public var savedWishes: [Wish] = []

    public init() {}

    public func save(_ wish: Wish) {
        savedWishes.insert(wish, at: 0)
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
