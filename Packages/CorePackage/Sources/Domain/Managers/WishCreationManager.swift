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

    /// Temporary, session-only generated candidates. Never persisted automatically —
    /// see WishLibraryManager for the explicit, user-initiated Save action.
    public var generatedWishes: WishGenerationResult?
    public var selectedVariant: WishVariant?

    /// The ElevenLabs provider voice ID chosen on the Voice screen, carried forward
    /// into Voice generation. The user always controls this — never inferred from
    /// occasion, recipient, relationship, or Wish variant.
    public var selectedVoiceID: String?

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
        generatedWishes = nil
        selectedVariant = nil
        selectedVoiceID = nil
        currentWishID = UUID()
    }

    public func finalizeWish() -> Wish {
        Wish(
            id: currentWishID,
            occasionKind: selectedOccasion?.kind ?? .other,
            occasionTitle: selectedOccasion?.title ?? currentForm.occasion,
            recipient: currentForm.relation,
            context: currentForm.note.isEmpty ? nil : currentForm.note,
            variant: selectedVariant ?? .natural,
            text: generatedText,
            selectedPackage: selectedPackage
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
