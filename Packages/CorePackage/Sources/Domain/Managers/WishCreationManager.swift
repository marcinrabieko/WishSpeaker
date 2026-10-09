import Dependencies
import Foundation

/// Holds the state of the wish currently being drafted, shared across the
/// Occasion → Form → Wishes → PackageSelection → FinalWish flow.
@MainActor
public final class WishCreationManager {
    public var currentForm = WishForm()
    public var generatedText = ""
    public var selectedPackage: PremiumPackage?
    public var selectedOccasion: Occasion?

    /// The occasion kind for the Wish being drafted. Kept separate from
    /// `selectedOccasion` because `loadExistingWish` only knows a saved Wish's kind —
    /// not the full `Occasion` (icon, subtitle) a fresh OccasionSelectionView pick has.
    public var occasionKind: OccasionKind?

    /// Temporary, session-only generated candidates. Never persisted automatically —
    /// see WishLibraryManager for the explicit, user-initiated Save action.
    public var generatedWishes: WishGenerationResult?
    public var selectedVariant: WishVariant?

    /// The greeting line from the most recent /api/generateWishes response (e.g.
    /// "Kochana Kasiu,"), carried forward into Video generation as a static headline.
    /// Separate from `generatedWishes.greeting` because a Wish loaded from the Library
    /// (loadExistingWish) has no fresh generation result to read it from.
    public var generatedGreeting: String?

    /// The ElevenLabs provider voice ID chosen on the Voice screen, carried forward
    /// into Voice generation. The user always controls this — never inferred from
    /// occasion, recipient, relationship, or Wish variant.
    public var selectedVoiceID: String?

    /// Result of the most recent successful Voice generation, carried into
    /// finalizeWish()/saveDraft() so the audio survives navigating back from VoiceView.
    public var generatedVoiceAsset: VoiceAsset?

    /// Result of the most recent successful Video generation, carried into
    /// finalizeWish()/saveDraft() so the video survives navigating back from VideoView.
    public var generatedVideoAsset: VideoAsset?

    /// Identity of the Wish this session may save to the Library. Kept stable across
    /// Save/Regenerate/finalize so a later voice/video asset lands on the same Library
    /// row instead of creating a duplicate entry for the same Wish.
    public private(set) var currentWishID = UUID()

    public init() {}

    public func startNewWish() {
        currentForm = WishForm()
        generatedText = ""
        selectedPackage = nil
        selectedOccasion = nil
        occasionKind = nil
        generatedWishes = nil
        generatedGreeting = nil
        selectedVariant = nil
        selectedVoiceID = nil
        generatedVoiceAsset = nil
        generatedVideoAsset = nil
        currentWishID = UUID()
    }

    /// Loads an already-saved Wish's state into the draft, e.g. before navigating from
    /// LibraryFeature's WishResultView into VoiceView to add a voice to a Wish that was
    /// saved text-only. Keeping `id` stable means a later save/generation updates that
    /// same Library row instead of creating a duplicate.
    public func loadExistingWish(_ wish: Wish) {
        currentForm = WishForm(occasion: wish.occasionTitle, relation: wish.recipient, note: wish.context ?? "")
        generatedText = wish.text
        selectedPackage = wish.selectedPackage
        selectedOccasion = nil
        occasionKind = wish.occasionKind
        generatedWishes = nil
        generatedGreeting = wish.greeting
        selectedVariant = wish.variant
        selectedVoiceID = nil
        generatedVoiceAsset = wish.voiceAsset
        generatedVideoAsset = wish.videoAsset
        currentWishID = wish.id
    }

    public func finalizeWish() -> Wish {
        Wish(
            id: currentWishID,
            occasionKind: selectedOccasion?.kind ?? occasionKind ?? .other,
            occasionTitle: selectedOccasion?.title ?? currentForm.occasion,
            recipient: currentForm.relation,
            context: currentForm.note.isEmpty ? nil : currentForm.note,
            variant: selectedVariant ?? .natural,
            text: generatedText,
            greeting: generatedGreeting,
            selectedPackage: selectedPackage,
            voiceAsset: generatedVoiceAsset,
            videoAsset: generatedVideoAsset
        )
    }
}

struct WishCreationManagerKey: DependencyKey {
    static var liveValue: WishCreationManager {
        @MainActor get { WishCreationManager() }
    }
}

public extension DependencyValues {
    var wishCreationManager: WishCreationManager {
        get { self[WishCreationManagerKey.self] }
        set { self[WishCreationManagerKey.self] = newValue }
    }
}
