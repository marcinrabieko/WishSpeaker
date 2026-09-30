import Foundation
import Observation

@MainActor
@Observable
public final class StartViewModel {
    var navigateToCreator = false
    var navigateToExamples = false
    var navigateToLibrary = false

    public init() {}

    func didTapCreateWish() {
        navigateToCreator = true
    }

    func didTapHearExample() {
        navigateToExamples = true
    }

    func didTapLibrary() {
        navigateToLibrary = true
    }
}
