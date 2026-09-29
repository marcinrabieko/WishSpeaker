import Dependencies
import Domain
import Localizations
import Observation

@MainActor
@Observable
public final class PackageSelectionViewModel {
    let packages: [PremiumPackage] = [
        PremiumPackage(
            name: L10n.packageBasicName,
            description: L10n.packageBasicDescription,
            price: 4.99,
            recommended: false
        ),
        PremiumPackage(
            name: L10n.packagePremiumName,
            description: L10n.packagePremiumDescription,
            price: 9.99,
            recommended: true
        ),
        PremiumPackage(
            name: L10n.packagePremiumPlusName,
            description: L10n.packagePremiumPlusDescription,
            price: 14.99,
            recommended: false
        )
    ]

    var navigateToFinal = false
    var selectedPackage: PremiumPackage?

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    public init() {}

    func didAppear() {
        selectedPackage = creationManager.selectedPackage
    }

    func didSelectPackage(_ package: PremiumPackage) {
        selectedPackage = package
        creationManager.selectedPackage = package
    }

    func didTapContinue() {
        navigateToFinal = true
    }
}
