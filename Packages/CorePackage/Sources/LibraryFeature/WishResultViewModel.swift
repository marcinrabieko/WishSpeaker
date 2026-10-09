import Dependencies
import Domain
import Foundation
import Observation
import SwiftUI

/// Where this Wish came from — determines Back's behavior (see didTapBackInCreationFlow)
/// since that's the only remaining difference between the two origins once both flows
/// render the same result screen.
enum WishResultOrigin {
    case library
    case creationFlow
}

@MainActor
@Observable
final class WishResultViewModel {
    var wish: Wish
    var isEditing = false
    var draftText = ""

    /// Mirrors `libraryManager.savedWishes.contains(wish.id)` as a plain, observed
    /// property instead of a computed one — `libraryManager` is `@ObservationIgnored`
    /// (it's a DI-resolved reference, not state this ViewModel owns), so a computed
    /// property reading through it would never register as a tracked dependency and
    /// the view would silently fail to re-render after Save for Later.
    var isSaved: Bool

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    /// A Wish already in the Library — reached by tapping a row in LibraryView.
    init(wish: Wish) {
        self.wish = wish
        isSaved = true
    }

    /// A freshly generated, not-yet-saved Wish — reached at the end of the
    /// Occasion → Form → Wishes flow. finalizeWish() reads the session draft
    /// WishCreationManager has been accumulating since Occasion selection.
    init(fromCreationDraft: Void) {
        @Dependency(\.wishCreationManager) var creationManager: WishCreationManager
        let finalizedWish = creationManager.finalizeWish()
        wish = finalizedWish

        @Dependency(\.wishLibraryManager) var libraryManager: WishLibraryManager
        isSaved = libraryManager.savedWishes.contains { $0.id == finalizedWish.id }
    }

    /// Re-reads this Wish from the Library (the source of truth once a row exists) and
    /// folds in any voice/video generated since — covers returning here from
    /// VoiceView/VideoView, for both a library-origin Wish and a creation-flow Wish
    /// that wasn't saved yet when the user left for Voice/Video generation.
    func didAppear() {
        if let savedWish = libraryManager.savedWishes.first(where: { $0.id == wish.id }) {
            wish = savedWish
            isSaved = true
        }

        var didGenerateNewAsset = false

        if let freshVoice = creationManager.generatedVoiceAsset, freshVoice.id != wish.voiceAsset?.id {
            wish = wish.withVoiceAsset(freshVoice)
            didGenerateNewAsset = true
        }

        if let freshVideo = creationManager.generatedVideoAsset, freshVideo.id != wish.videoAsset?.id {
            wish = wish.withVideoAsset(freshVideo)
            didGenerateNewAsset = true
        }

        // Generated voice/video is never left unsaved, and generating one after an
        // earlier text-only save must update that same Library row — otherwise a user
        // who saved the text first, then generated a voice/video, ends up with it
        // silently missing from the already-saved Wish.
        if didGenerateNewAsset {
            libraryManager.save(wish)
            isSaved = true
        }
    }

    func didTapCreateVoice() {
        creationManager.loadExistingWish(wish)
    }

    func didTapCreateVideo() {
        creationManager.loadExistingWish(wish)
    }

    func didTapSaveForLater() {
        libraryManager.save(wish)
        isSaved = true
    }

    /// Replaces the saved text in place — same Wish id, so the Library keeps one row
    /// for this Wish rather than gaining a duplicate entry. Only persists immediately
    /// when the Wish is already saved; an unsaved creation-flow draft stays session-only
    /// until the user explicitly taps Save for Later, so editing text alone never forces
    /// an early save.
    func didSaveEditedText(_ text: String) {
        wish = wish.withText(text)

        if isSaved {
            libraryManager.save(wish)
        }
    }

    /// Once a voice/video has been generated, this screen is a terminal step in the
    /// creation flow — Back returns all the way to Start instead of walking back through
    /// Occasion/Form/Wishes, which would just re-show already-submitted choices.
    func didTapBackInCreationFlow(path: Binding<NavigationPath>) {
        if wish.voiceAsset != nil || wish.videoAsset != nil {
            path.wrappedValue.removeLast(path.wrappedValue.count)
        } else {
            path.wrappedValue.removeLast()
        }
    }
}

private extension Wish {
    func withText(_ text: String) -> Wish {
        Wish(
            id: id,
            occasionKind: occasionKind,
            occasionTitle: occasionTitle,
            recipient: recipient,
            context: context,
            variant: variant,
            text: text,
            greeting: greeting,
            language: language,
            createdAt: createdAt,
            updatedAt: Date(),
            selectedPackage: selectedPackage,
            voiceAsset: voiceAsset,
            videoAsset: videoAsset
        )
    }

    func withVoiceAsset(_ voiceAsset: VoiceAsset) -> Wish {
        Wish(
            id: id,
            occasionKind: occasionKind,
            occasionTitle: occasionTitle,
            recipient: recipient,
            context: context,
            variant: variant,
            text: text,
            greeting: greeting,
            language: language,
            createdAt: createdAt,
            updatedAt: Date(),
            selectedPackage: selectedPackage,
            voiceAsset: voiceAsset,
            videoAsset: videoAsset
        )
    }

    func withVideoAsset(_ videoAsset: VideoAsset) -> Wish {
        Wish(
            id: id,
            occasionKind: occasionKind,
            occasionTitle: occasionTitle,
            recipient: recipient,
            context: context,
            variant: variant,
            text: text,
            greeting: greeting,
            language: language,
            createdAt: createdAt,
            updatedAt: Date(),
            selectedPackage: selectedPackage,
            voiceAsset: voiceAsset,
            videoAsset: videoAsset
        )
    }
}
