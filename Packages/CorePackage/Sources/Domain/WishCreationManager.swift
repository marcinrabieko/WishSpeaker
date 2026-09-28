import Foundation
import Dependencies

/// Holds the state of the wish currently being drafted, shared across the
/// Occasion → Form → GeneratedPreview → PackageSelection → FinalWish flow.
@MainActor
public final class WishCreationManager {
    public var currentForm = WishForm()
    public var generatedText = ""
    public var selectedPackage: PremiumPackage?

    public init() {}

    public func startNewWish() {
        currentForm = WishForm()
        generatedText = ""
        selectedPackage = nil
    }

    public func finalizeWish() -> Wish {
        Wish(
            form: currentForm,
            generatedText: generatedText,
            selectedPackage: selectedPackage
        )
    }
}

extension WishCreationManager: DependencyKey {
    public static var defaultValue: WishCreationManager {
        @MainActor get { shared }
    }

    @MainActor private static let shared = WishCreationManager()
}

public extension DependencyValues {
    var wishCreationManager: WishCreationManager {
        get { self[WishCreationManager.self] }
        set { self[WishCreationManager.self] = newValue }
    }
}
