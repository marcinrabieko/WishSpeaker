import Dependencies
import Domain
import Observation

enum VoiceRowState {
    case loading
    case loaded(VoiceOption)
    case failed(providerVoiceID: String)
}

@MainActor
@Observable
public final class VoiceViewModel {
    var occasionTitle = ""
    var variantDisplayName = ""
    var wishText = ""
    var isShowingText = false

    var voiceRows: [VoiceRowState] = [.loading, .loading]
    var selectedProviderVoiceID: String?

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    @ObservationIgnored
    @Dependency(\.voiceMetadataService)
    private var voiceMetadataService: any VoiceMetadataService

    public init() {}

    var isGenerateEnabled: Bool {
        selectedProviderVoiceID != nil
    }

    func didAppear() {
        occasionTitle = creationManager.selectedOccasion?.title ?? creationManager.currentForm.occasion
        variantDisplayName = (creationManager.selectedVariant ?? .natural).displayName
        wishText = creationManager.generatedText
        selectedProviderVoiceID = creationManager.selectedVoiceID

        guard voiceRows.allSatisfy(\.isLoading) else {
            return
        }

        Task {
            await loadVoices()
        }
    }

    func didTapShowText() {
        isShowingText.toggle()
    }

    func didSelectVoice(_ voice: VoiceOption) {
        selectedProviderVoiceID = voice.providerVoiceID
        creationManager.selectedVoiceID = voice.providerVoiceID
    }

    func didTapRetry() {
        Task {
            await loadVoices()
        }
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

        selectDefaultVoiceIfNeeded(from: loadedVoices)
    }

    /// Picks a deterministic default (the catalog's first successfully loaded voice)
    /// once metadata is available — never inferred from occasion/recipient/relationship/
    /// variant, and never overrides a choice the user already made this session.
    private func selectDefaultVoiceIfNeeded(from loadedVoices: [VoiceOption]) {
        guard selectedProviderVoiceID == nil, let firstVoice = loadedVoices.first else {
            return
        }

        didSelectVoice(firstVoice)
    }
}

private extension VoiceRowState {
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
