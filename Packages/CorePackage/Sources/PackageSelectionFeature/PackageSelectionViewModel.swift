import Dependencies
import Domain
import Observation

@MainActor
@Observable
public final class PackageSelectionViewModel {
    let packages: [PremiumPackage] = [
        PremiumPackage(
            name: "Basic",
            description: "Standard AI voice",
            price: 4.99,
            recommended: false
        ),
        PremiumPackage(
            name: "Premium",
            description: "Studio voice",
            price: 9.99,
            recommended: true
        ),
        PremiumPackage(
            name: "Premium Plus",
            description: "Studio voice + music",
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
