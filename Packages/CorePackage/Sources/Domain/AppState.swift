import Foundation

public class AppState: ObservableObject {
    @Published public var hasGeneratedWish: Bool = false
    @Published public var generatedWishes: [Wish] = []
    @Published public var currentForm: WishForm = WishForm()
    @Published public var generatedText: String = ""
    @Published public var selectedPackage: PremiumPackage?

    public init() {}

    public func resetForm() {
        currentForm = WishForm()
        generatedText = ""
        selectedPackage = nil
    }

    public func saveWish() {
        let wish = Wish(
            form: currentForm,
            generatedText: generatedText,
            selectedPackage: selectedPackage
        )
        generatedWishes.insert(wish, at: 0)
        hasGeneratedWish = true
    }
}
