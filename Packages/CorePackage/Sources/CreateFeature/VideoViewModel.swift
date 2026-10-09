import Dependencies
import Domain
import Foundation
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

    /// Readable local audio file for the Wish's existing VoiceAsset, if any. Checking
    /// the file (not just the model) means a VoiceAsset whose file was deleted or
    /// corrupted falls back to the normal narrator-selection + fresh-generation flow
    /// instead of silently failing to render a video.
    private(set) var reusableVoiceAsset: VoiceAsset?

    /// True once the existing-audio check has run — gates showing either the reuse
    /// notice or the narrator picker, so neither flashes before the file check finishes.
    private(set) var hasResolvedExistingAudio = false

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
        (reusableVoiceAsset != nil || selectedVoice != nil) && !isGenerating
    }

    func didAppear() {
        occasionTitle = creationManager.selectedOccasion?.title ?? creationManager.currentForm.occasion
        variantDisplayName = (creationManager.selectedVariant ?? .natural).displayName
        wishText = creationManager.generatedText

        guard !hasResolvedExistingAudio else {
            return
        }

        hasResolvedExistingAudio = true

        if let existingVoiceAsset = creationManager.generatedVoiceAsset, existingVoiceAsset.audioURL != nil {
            reusableVoiceAsset = existingVoiceAsset
            return
        }

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
        guard let request = makeGenerationRequest() else { return }

        generationError = nil
        isGenerating = true

        Task {
            do {
                let videoAsset = try await videoGenerationService.generateVideo(for: request)

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

    /// Reusing an existing VoiceAsset never touches `selectedVoice` (the narrator
    /// picker is skipped entirely), so the two cases build their own request rather than
    /// sharing the voiceGender/providerVoiceID fields a fresh-generation request needs.
    private func makeGenerationRequest() -> VideoGenerationRequest? {
        if let reusableVoiceAsset {
            guard let audioURL = reusableVoiceAsset.audioURL, let audioData = try? Data(contentsOf: audioURL) else {
                return nil
            }

            return VideoGenerationRequest(
                text: wishText,
                occasionKind: creationManager.selectedOccasion?.kind ?? creationManager.occasionKind,
                existingAudio: VideoGenerationRequest.ExistingAudio(
                    data: audioData,
                    fileExtension: audioURL.pathExtension
                )
            )
        }

        guard let selectedVoice else { return nil }

        return VideoGenerationRequest(
            text: wishText,
            voiceGender: selectedVoice.gender,
            providerVoiceID: selectedVoice.providerVoiceID,
            occasionKind: creationManager.selectedOccasion?.kind ?? creationManager.occasionKind
        )
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
            voiceAsset: reusableVoiceAsset ?? creationManager.generatedVoiceAsset,
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
