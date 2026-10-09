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

    /// Deletes the persisted Wish together with any local media files its Voice/Video
    /// assets reference, so deleting a Library row never leaves orphaned files behind.
    public func delete(_ wish: Wish) {
        let context = modelContainer.mainContext
        let wishID = wish.id
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == wishID })

        guard let model = try? context.fetch(descriptor).first else {
            return
        }

        deleteLocalMediaFiles(for: model)
        context.delete(model)
        try? context.save()
        fetchSavedWishes()
    }

    private func deleteLocalMediaFiles(for model: WishModel) {
        [
            model.voiceAudioFileReference,
            model.voiceWordTimestampsFileReference,
            model.videoFileReference,
            model.videoThumbnailReference
        ]
        .compactMap { $0 }
        .forEach(WishLibraryManager.deleteFileIfExists)
    }

    private static func deleteFileIfExists(named fileName: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        try? FileManager.default.removeItem(at: fileURL)
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
