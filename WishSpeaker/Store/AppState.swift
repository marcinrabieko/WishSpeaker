import Foundation

class AppState: ObservableObject {
    @Published var hasGeneratedWish: Bool = false
    @Published var generatedWishes: [Wish] = []
    @Published var currentForm: WishForm = WishForm()
    @Published var generatedText: String = ""
    @Published var selectedPackage: PremiumPackage?

    func resetForm() {
        currentForm = WishForm()
        generatedText = ""
        selectedPackage = nil
    }

    func saveWish() {
        let wish = Wish(
            form: currentForm,
            generatedText: generatedText,
            selectedPackage: selectedPackage
        )
        generatedWishes.insert(wish, at: 0)
        hasGeneratedWish = true
    }
}
