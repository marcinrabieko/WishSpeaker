import SwiftUI

private struct WSBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    let onDismiss: (() -> Void)?
    let homeAction: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .background(InteractivePopGestureEnabler(isEnabled: homeAction == nil))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if let homeAction {
                            homeAction()
                        } else {
                            onDismiss?()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: homeAction == nil ? "chevron.left" : "house")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.wsPrimaryText)
                            .frame(width: WSSize.minTapTarget, height: WSSize.minTapTarget)
                    }
                }
            }
    }
}

/// `.navigationBarBackButtonHidden(true)` also disables the edge-swipe-to-go-back gesture.
/// This invisible child controller re-enables it (or keeps it disabled when `isEnabled` is
/// false) on every appearance — SwiftUI can disable it again while updating the bar — and swaps
/// in a delegate that only lets it begin when there is something to pop, since a swipe on the
/// root screen would otherwise freeze the navigation stack.
private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    let isEnabled: Bool

    func makeUIViewController(context: Context) -> EnablerViewController {
        EnablerViewController()
    }

    func updateUIViewController(_ uiViewController: EnablerViewController, context: Context) {
        uiViewController.isPopGestureEnabled = isEnabled
    }

    final class EnablerViewController: UIViewController {
        // Only applied while this screen is the visible one — an update can arrive while
        // another screen is pushed on top, and must not change that screen's gesture.
        private var isVisible = false

        var isPopGestureEnabled = true {
            didSet {
                guard isVisible else {
                    return
                }

                applyPopGestureState()
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            isVisible = true
            applyPopGestureState()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            isVisible = false
        }

        private func applyPopGestureState() {
            guard let popGesture = navigationController?.interactivePopGestureRecognizer else {
                return
            }

            popGesture.isEnabled = isPopGestureEnabled
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
        modifier(WSBackButtonModifier(onDismiss: onDismiss, homeAction: nil))
    }

    /// Like `wsBackButton()`, but while `homeAction` is non-nil the chevron becomes a house icon
    /// whose tap runs `homeAction` (e.g. popping to the root), and the swipe-to-go-back gesture
    /// is disabled — it can only pop a single level, so it can't follow `homeAction`. Passing
    /// `nil` behaves exactly like `wsBackButton()`.
    func wsBackButton(homeAction: (() -> Void)?) -> some View {
        modifier(WSBackButtonModifier(onDismiss: nil, homeAction: homeAction))
    }
}
