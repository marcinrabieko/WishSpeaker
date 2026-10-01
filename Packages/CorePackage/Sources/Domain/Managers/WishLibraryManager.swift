import Dependencies
import Foundation
import SwiftData

/// Holds the persistent library of wishes the user has already created, backed by
/// SwiftData. The rest of the app only ever sees the domain `Wish` struct — mapping
/// to/from the SwiftData-managed `WishModel` is entirely contained here.
///
/// One Wish = one Library row. A Wish can evolve over time — text only, then
/// text + voice, then text + voice + video — so saving a Wish with an id that
/// already exists replaces that row in place rather than appending a duplicate.
@MainActor
public final class WishLibraryManager {
    public private(set) var savedWishes: [Wish] = []

    private let modelContainer: ModelContainer

    public init() {
        modelContainer = WishLibraryManager.makeModelContainer()
        fetchSavedWishes()
        seedSampleWishesIfNeeded()
    }

    public func save(_ wish: Wish) {
        let context = modelContainer.mainContext
        let wishID = wish.id
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == wishID })

        if let existing = try? context.fetch(descriptor).first {
            existing.update(from: wish)
        } else {
            context.insert(WishModel(wish: wish))
        }

        try? context.save()
        fetchSavedWishes()
    }

    private func fetchSavedWishes() {
        let descriptor = FetchDescriptor<WishModel>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let models = (try? modelContainer.mainContext.fetch(descriptor)) ?? []

        savedWishes = models.map(\.asWish)
    }

    private static func makeModelContainer() -> ModelContainer {
        // swiftlint:disable:next force_try
        try! ModelContainer(for: WishModel.self)
    }

    /// Hardcoded on-device seed data, on by hand — three starter wishes (text, voice,
    /// video) so the Library isn't empty on first launch. Only runs once: skipped the
    /// moment the user has any wish of their own saved.
    private func seedSampleWishesIfNeeded() {
        guard savedWishes.isEmpty else {
            return
        }

        for wish in LibraryPreviewData.all {
            save(wish)
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
