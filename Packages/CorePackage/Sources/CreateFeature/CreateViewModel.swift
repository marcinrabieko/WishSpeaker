import Dependencies
import Domain
import Localizations
import Observation
import SwiftUI

@MainActor
@Observable
public final class CreateViewModel {
    var isEditing = false
    var draftText = ""
    var isSaved = false
    var voiceAsset: VoiceAsset?
    var videoAsset: VideoAsset?
    var isShowingFullText = false

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    public init() {}

    var occasionTitle: String {
        creationManager.selectedOccasion?.title ?? creationManager.currentForm.occasion
    }

    /// "Create" only describes this screen before anything has been generated yet —
    /// once a voice/video exists, the screen is presenting a finished result, not a
    /// creation step.
    var navigationTitle: String {
        voiceAsset != nil || videoAsset != nil ? L10n.createViewFinishedTitle : L10n.createViewTitle
    }

    var variant: WishVariant {
        creationManager.selectedVariant ?? .natural
    }

    func didAppear() {
        draftText = creationManager.generatedText
        voiceAsset = creationManager.generatedVoiceAsset
        videoAsset = creationManager.generatedVideoAsset

        let savedWish = libraryManager.savedWishes.first { $0.id == creationManager.currentWishID }
        isSaved = savedWish != nil

        // Generated voice/video is never left unsaved, and a voice/video generated
        // after an earlier text-only save must update that same Library row —
        // otherwise a user who saved the text first, then generated a voice/video,
        // ends up with it silently missing from the already-saved Wish.
        let voiceChanged = voiceAsset != nil && savedWish?.voiceAsset?.id != voiceAsset?.id
        let videoChanged = videoAsset != nil && savedWish?.videoAsset?.id != videoAsset?.id

        if voiceChanged || videoChanged {
            saveDraft()
            isSaved = true
        }
    }

    func didTapEdit() {
        isEditing = true
    }

    func didTapShowFullText() {
        isShowingFullText.toggle()
    }

    func didTapDoneEditing() {
        creationManager.generatedText = draftText
        isEditing = false

        if isSaved {
            saveDraft()
        }
    }

    func didTapSaveForLater() {
        saveDraft()
        isSaved = true
    }

    func didTapVoice(path: Binding<NavigationPath>) {
        creationManager.generatedText = draftText
        path.wrappedValue.append(CreateFlowRoute.voice)
    }

    func didTapVideoCard(path: Binding<NavigationPath>) {
        creationManager.generatedText = draftText
        path.wrappedValue.append(CreateFlowRoute.videoCard)
    }

    /// Once a voice/video has been generated, this screen is a terminal step in the
    /// flow — Back returns all the way to Start instead of walking back through
    /// Occasion/Form/Wishes, which would just re-show already-submitted choices.
    func didTapBack(path: Binding<NavigationPath>) {
        if voiceAsset != nil || videoAsset != nil {
            path.wrappedValue.removeLast(path.wrappedValue.count)
        } else {
            path.wrappedValue.removeLast()
        }
    }

    private func saveDraft() {
        let form = creationManager.currentForm
        let wish = Wish(
            id: creationManager.currentWishID,
            occasionKind: creationManager.selectedOccasion?.kind ?? creationManager.occasionKind ?? .other,
            occasionTitle: creationManager.selectedOccasion?.title ?? form.occasion,
            recipient: form.relation,
            context: form.note.isEmpty ? nil : form.note,
            variant: variant,
            text: draftText,
            greeting: creationManager.generatedGreeting,
            voiceAsset: voiceAsset,
            videoAsset: videoAsset
        )

        libraryManager.save(wish)
    }
}
