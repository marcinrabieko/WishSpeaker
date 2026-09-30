import Dependencies
import Domain
import Foundation
import Observation

@MainActor
@Observable
final class WishDetailViewModel {
    var wish: Wish

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    init(wish: Wish) {
        self.wish = wish
    }

    /// Replaces the saved text in place — same Wish id, so the Library keeps one row
    /// for this Wish rather than gaining a duplicate entry.
    func didSaveEditedText(_ text: String) {
        let updated = Wish(
            id: wish.id,
            occasionKind: wish.occasionKind,
            occasionTitle: wish.occasionTitle,
            recipient: wish.recipient,
            context: wish.context,
            variant: wish.variant,
            text: text,
            language: wish.language,
            createdAt: wish.createdAt,
            updatedAt: Date(),
            selectedPackage: wish.selectedPackage,
            voiceAsset: wish.voiceAsset,
            videoAsset: wish.videoAsset
        )

        libraryManager.save(updated)
        wish = updated
    }
}
