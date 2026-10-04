import Dependencies
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class StartViewModel {
    var navigateToCreator = false
    var navigateToExamples = false
    var navigateToLibrary = false

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    public init() {}

    func didTapCreateWish() {
        creationManager.startNewWish()
        navigateToCreator = true
    }

    func didTapHearExample() {
        navigateToExamples = true
    }

    func didTapLibrary() {
        navigateToLibrary = true
    }
}
