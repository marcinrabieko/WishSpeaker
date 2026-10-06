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

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    public init() {}

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
