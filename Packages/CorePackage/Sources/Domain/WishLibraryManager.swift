import Foundation
import Dependencies

/// Holds the persistent library of wishes the user has already created.
@MainActor
public final class WishLibraryManager {
    public var savedWishes: [Wish] = []

    public init() {}

    public func save(_ wish: Wish) {
        savedWishes.insert(wish, at: 0)
    }
}

extension WishLibraryManager: DependencyKey {
    public static var defaultValue: WishLibraryManager {
        @MainActor get { shared }
    }

    @MainActor private static let shared = WishLibraryManager()
}

public extension DependencyValues {
    var wishLibraryManager: WishLibraryManager {
        get { self[WishLibraryManager.self] }
        set { self[WishLibraryManager.self] = newValue }
    }
}
