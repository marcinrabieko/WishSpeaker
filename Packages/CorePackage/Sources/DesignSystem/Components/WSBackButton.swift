import SwiftUI

private struct WSBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss?()
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
    ///
    /// - Parameter onDismiss: Optional cleanup run right before the view is popped (e.g. clearing
    ///   focus state). Not called when the user swipes back instead of tapping the button.
    func wsBackButton(onDismiss: (() -> Void)? = nil) -> some View {
        modifier(WSBackButtonModifier(onDismiss: onDismiss))
    }
}
