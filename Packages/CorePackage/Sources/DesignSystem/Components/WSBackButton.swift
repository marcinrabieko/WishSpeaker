import SwiftUI

private struct WSBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    let onDismiss: (() -> Void)?
    let customAction: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .background(InteractivePopGestureEnabler())
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if let customAction {
                            customAction()
                        } else {
                            onDismiss?()
                            dismiss()
                        }
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

/// `.navigationBarBackButtonHidden(true)` also disables the edge-swipe-to-go-back gesture.
/// This invisible child controller re-enables it on every appearance (SwiftUI can disable it
/// again while updating the bar) and swaps in a delegate that only lets it begin when there is
/// something to pop — a swipe on the root screen would otherwise freeze the navigation stack.
private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> EnablerViewController {
        EnablerViewController()
    }

    func updateUIViewController(_ uiViewController: EnablerViewController, context: Context) {}

    final class EnablerViewController: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            guard let popGesture = navigationController?.interactivePopGestureRecognizer else {
                return
            }

            popGesture.isEnabled = true
            popGesture.delegate = PopGestureDelegate.shared
        }
    }
}

/// Stateless and shared on purpose: `UIGestureRecognizer.delegate` is weak, so a per-screen
/// delegate would be released when its screen is popped, leaving the gesture unguarded on root.
@MainActor
private final class PopGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = PopGestureDelegate()

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = gestureRecognizer.view?.next as? UINavigationController else {
            return false
        }

        return navigationController.viewControllers.count > 1
    }
}

public extension View {
    /// Replaces the system back button with WishSpeaker's custom chevron style, while staying in
    /// the same `NavigationStack` — the native swipe-to-go-back gesture keeps working.
    ///
    /// - Parameter onDismiss: Optional cleanup run right before the view is popped (e.g. clearing
    ///   focus state). Not called when the user swipes back instead of tapping the button.
    func wsBackButton(onDismiss: (() -> Void)? = nil) -> some View {
        modifier(WSBackButtonModifier(onDismiss: onDismiss, customAction: nil))
    }

    /// Replaces the system back button's tap action entirely (e.g. popping multiple
    /// screens at once) instead of the default single-level `dismiss()`. The native
    /// swipe-to-go-back gesture still only pops one level — this only affects the
    /// button tap.
    func wsBackButton(customAction: @escaping () -> Void) -> some View {
        modifier(WSBackButtonModifier(onDismiss: nil, customAction: customAction))
    }
}
