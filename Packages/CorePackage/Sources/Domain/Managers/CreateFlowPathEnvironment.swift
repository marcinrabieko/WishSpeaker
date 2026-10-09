import SwiftUI

private struct CreateFlowPathKey: EnvironmentKey {
    static var defaultValue: Binding<NavigationPath> {
        .constant(NavigationPath())
    }
}

public extension EnvironmentValues {
    /// Binding to the app's root NavigationPath, injected once at the NavigationStack
    /// and read by any screen in the Start → Occasion → Form → Wishes → Create chain
    /// that needs to pop back to Start after a terminal action — e.g. a successful
    /// Voice generation on the Create result screen — without needing a reference to
    /// every intermediate screen on the stack.
    var createFlowPath: Binding<NavigationPath> {
        get { self[CreateFlowPathKey.self] }
        set { self[CreateFlowPathKey.self] = newValue }
    }
}
