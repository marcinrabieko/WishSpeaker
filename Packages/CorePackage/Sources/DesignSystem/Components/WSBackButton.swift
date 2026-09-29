import SwiftUI

private struct WSBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.wsPrimaryText)
                            .frame(width: WSSize.minTapTarget, height: WSSize.minTapTarget)
                    }
                }
            }
    }
}

public extension View {
    /// Replaces the system back button with WishSpeaker's custom chevron style, while staying in
    /// the same `NavigationStack` — the native swipe-to-go-back gesture keeps working.
    func wsBackButton() -> some View {
        modifier(WSBackButtonModifier())
    }
}
