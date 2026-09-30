import Dependencies
import Domain
import Observation

@MainActor
@Observable
public final class CreateViewModel {
    var isEditing = false
    var draftText = ""
    var isSaved = false
    var navigateToVoice = false
    var navigateToVideoCard = false

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

    var variant: WishVariant {
        creationManager.selectedVariant ?? .natural
    }

    func didAppear() {
        draftText = creationManager.generatedText
        isSaved = libraryManager.savedWishes.contains { $0.id == creationManager.currentWishID }
    }

    func didTapEdit() {
        isEditing = true
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

    func didTapVoice() {
        creationManager.generatedText = draftText
        navigateToVoice = true
    }

    func didTapVideoCard() {
        creationManager.generatedText = draftText
        navigateToVideoCard = true
    }

    private func saveDraft() {
        let form = creationManager.currentForm
        let wish = Wish(
            id: creationManager.currentWishID,
            occasionKind: creationManager.selectedOccasion?.kind ?? .other,
            occasionTitle: creationManager.selectedOccasion?.title ?? form.occasion,
            recipient: form.relation,
            context: form.note.isEmpty ? nil : form.note,
            variant: variant,
            text: draftText
        )

        libraryManager.save(wish)
    }
}
