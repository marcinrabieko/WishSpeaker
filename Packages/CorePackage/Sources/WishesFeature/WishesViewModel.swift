import Dependencies
import Domain
import Observation
import UIKit

enum WishesLoadState {
    case loading
    case loaded
    case failed
}

@MainActor
@Observable
public final class WishesViewModel {
    var loadState: WishesLoadState = .loading
    var wishes: WishGenerationResult?
    var expandedVariant: WishVariant? = .warm
    var regeneratingVariant: WishVariant?
    var regenerationErrorVariant: WishVariant?
    var copiedVariant: WishVariant?
    var savedVariants: Set<WishVariant> = []
    var navigateToNextStep = false

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    @ObservationIgnored
    @Dependency(\.wishGenerationService)
    private var generationService: any WishGenerationService

    public init() {}

    func didAppear() {
        guard wishes == nil else {
            return
        }

        if let cached = creationManager.generatedWishes {
            wishes = cached
            loadState = .loaded
            return
        }

        generateInitialWishes()
    }

    func didTapRetry() {
        generateInitialWishes()
    }

    func didTapToggle(_ variant: WishVariant) {
        expandedVariant = expandedVariant == variant ? nil : variant
    }

    func didTapCopy(_ variant: WishVariant) {
        guard let text = wishes?.text(for: variant) else {
            return
        }

        UIPasteboard.general.string = text
        copiedVariant = variant

        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)

            if copiedVariant == variant {
                copiedVariant = nil
            }
        }
    }

    func didTapSave(_ variant: WishVariant) {
        guard let text = wishes?.text(for: variant) else {
            return
        }

        let form = creationManager.currentForm
        let wish = Wish(
            id: creationManager.currentWishID,
            occasionKind: creationManager.selectedOccasion?.kind ?? .other,
            occasionTitle: creationManager.selectedOccasion?.title ?? form.occasion,
            recipient: form.relation,
            context: form.note.isEmpty ? nil : form.note,
            variant: variant,
            text: text
        )

        libraryManager.save(wish)
        savedVariants.insert(variant)
    }

    func didTapUseThisWish(_ variant: WishVariant) {
        guard let text = wishes?.text(for: variant) else {
            return
        }

        creationManager.selectedVariant = variant
        creationManager.generatedText = text
        navigateToNextStep = true
    }

    func didTapRegenerate(_ variant: WishVariant) {
        guard regeneratingVariant == nil, let previousText = wishes?.text(for: variant) else {
            return
        }

        regenerationErrorVariant = nil
        regeneratingVariant = variant

        Task {
            do {
                let request = makeRequest()
                let newText = try await generationService.regenerateWish(
                    for: request,
                    variant: variant,
                    previousText: previousText
                )

                wishes?.setText(newText, for: variant)
                creationManager.generatedWishes = wishes
                savedVariants.remove(variant)
                regeneratingVariant = nil
            } catch {
                regeneratingVariant = nil
                regenerationErrorVariant = variant
            }
        }
    }

    private func generateInitialWishes() {
        loadState = .loading

        Task {
            do {
                let request = makeRequest()
                let result = try await generationService.generateWishes(for: request)

                wishes = result
                creationManager.generatedWishes = result
                expandedVariant = .warm
                loadState = .loaded
            } catch {
                loadState = .failed
            }
        }
    }

    private func makeRequest() -> WishGenerationRequest {
        WishGenerationRequest(
            form: creationManager.currentForm,
            occasionKind: creationManager.selectedOccasion?.kind ?? .other
        )
    }
}
