import Dependencies
import Domain
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
public final class StartViewModel {
    var navigateToExamples = false
    var navigateToLibrary = false
    var hasSavedWishes = false

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    @ObservationIgnored
    @Dependency(\.purchaseManager)
    private var purchaseManager: PurchaseManager

    public init() {}

    func didAppear() {
        purchaseManager.start()
        hasSavedWishes = !libraryManager.savedWishes.isEmpty
    }

    func didTapCreateWish(path: Binding<NavigationPath>) {
        creationManager.startNewWish()
        path.wrappedValue.append(CreateFlowRoute.occasionSelection)
    }

    func didTapHearExample() {
        navigateToExamples = true
    }

    func didTapLibrary() {
        navigateToLibrary = true
    }
}
