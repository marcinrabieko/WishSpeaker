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

    public init() {}

    public func startNewWish() {
        currentForm = WishForm()
        generatedText = ""
        selectedPackage = nil
        selectedOccasion = nil
        generatedWishes = nil
        selectedVariant = nil
    }

    public func finalizeWish() -> Wish {
        Wish(
            form: currentForm,
            generatedText: generatedText,
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
