import Dependencies
import Domain
import Localizations
import Observation

@MainActor
@Observable
public final class VideoViewModel {
    var occasionTitle = ""
    var variantDisplayName = ""
    var wishText = ""

    var voiceRows: [VoiceRowState] = [.loading, .loading]
    var selectedVoice: VoiceOption?

    var isGenerating = false
    var generationError: String?
    var navigateBackAfterGeneration = false

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    @ObservationIgnored
    @Dependency(\.voiceMetadataService)
    private var voiceMetadataService: any VoiceMetadataService

    @ObservationIgnored
    @Dependency(\.videoGenerationService)
    private var videoGenerationService: any VideoGenerationService

    public init() {}

    var isGenerateEnabled: Bool {
        selectedVoice != nil && !isGenerating
    }

    func didAppear() {
        occasionTitle = creationManager.selectedOccasion?.title ?? creationManager.currentForm.occasion
        variantDisplayName = (creationManager.selectedVariant ?? .natural).displayName
        wishText = creationManager.generatedText

        guard voiceRows.allSatisfy(\.isLoading) else {
            return
        }

        Task {
            await loadVoices()
        }
    }

    func didSelectVoice(_ voice: VoiceOption) {
        selectedVoice = voice
        creationManager.selectedVoiceID = voice.providerVoiceID
    }

    func didTapRetry() {
        Task {
            await loadVoices()
        }
    }

    func didTapGenerate() {
        guard let selectedVoice else { return }

        generationError = nil
        isGenerating = true

        Task {
            do {
                let videoAsset = try await videoGenerationService.generateVideo(
                    for: VideoGenerationRequest(
                        text: wishText,
                        voiceGender: selectedVoice.gender,
                        providerVoiceID: selectedVoice.providerVoiceID,
                        occasionKind: creationManager.selectedOccasion?.kind ?? creationManager.occasionKind
                    )
                )

                creationManager.generatedVideoAsset = videoAsset
                saveToLibrary(videoAsset: videoAsset)
                isGenerating = false
                navigateBackAfterGeneration = true
            } catch {
                isGenerating = false
                generationError = L10n.videoViewGenerationError
            }
        }
    }

    /// Persists the video directly to the Library the moment generation succeeds,
    /// before navigating back to WishResultView — belt-and-suspenders alongside
    /// WishResultViewModel.didAppear(), which also saves on return if it sees a new
    /// videoAsset creationManager doesn't yet have reflected in the Library. `save(_:)`
    /// updates the existing Library row in place when `currentWishID` already exists,
    /// so neither save path creates a duplicate.
    private func saveToLibrary(videoAsset: VideoAsset) {
        let form = creationManager.currentForm
        let wish = Wish(
            id: creationManager.currentWishID,
            occasionKind: creationManager.selectedOccasion?.kind ?? creationManager.occasionKind ?? .other,
            occasionTitle: creationManager.selectedOccasion?.title ?? form.occasion,
            recipient: form.relation,
            context: form.note.isEmpty ? nil : form.note,
            variant: creationManager.selectedVariant ?? .natural,
            text: wishText,
            voiceAsset: creationManager.generatedVoiceAsset,
            videoAsset: videoAsset
        )

        libraryManager.save(wish)
    }

    private func loadVoices() async {
        voiceRows = VoiceCatalog.curatedVoiceIDs.map { _ in .loading }

        let loadedVoices = await voiceMetadataService.fetchCuratedVoices()

        voiceRows = VoiceCatalog.curatedVoiceIDs.map { providerVoiceID in
            if let voice = loadedVoices.first(where: { $0.providerVoiceID == providerVoiceID }) {
                return .loaded(voice)
            }
            return .failed(providerVoiceID: providerVoiceID)
        }

        restoreOrSelectDefaultVoice(from: loadedVoices)
    }

    /// Restores the user's prior choice (e.g. returning to this screen) if it's still
    /// in the loaded catalog, otherwise picks a deterministic default — the catalog's
    /// first successfully loaded voice. Never inferred from occasion/recipient/
    /// relationship/variant, and never overrides a choice made earlier this session.
    private func restoreOrSelectDefaultVoice(from loadedVoices: [VoiceOption]) {
        if let previouslySelectedID = creationManager.selectedVoiceID,
           let restored = loadedVoices.first(where: { $0.providerVoiceID == previouslySelectedID }) {
            selectedVoice = restored
            return
        }

        guard let firstVoice = loadedVoices.first else {
            return
        }

        didSelectVoice(firstVoice)
    }
}
