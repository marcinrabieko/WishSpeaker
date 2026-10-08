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

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    init(wish: Wish) {
        self.wish = wish
    }

    /// Re-reads this Wish from the Library — e.g. after returning from VoiceView, which
    /// may have added a voiceAsset to this same Wish via WishCreationManager.
    func didAppear() {
        if let refreshed = libraryManager.savedWishes.first(where: { $0.id == wish.id }) {
            wish = refreshed
        }
    }

    /// Loads this Wish into the shared creation draft before navigating into VoiceView,
    /// so a voice generated there updates this same Library row instead of creating a
    /// new one.
    func didTapCreateVoice() {
        creationManager.loadExistingWish(wish)
    }

    /// Loads this Wish into the shared creation draft before navigating into VideoView,
    /// so a video generated there updates this same Library row instead of creating a
    /// new one.
    func didTapCreateVideo() {
        creationManager.loadExistingWish(wish)
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
            greeting: wish.greeting,
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
