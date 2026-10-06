import Foundation

/// A step in the Start → Occasion → Form → Wishes → Create → Voice/VideoCard flow,
/// pushed onto the shared NavigationPath owned by the app's root NavigationStack.
/// Keeping this flat (one enum, one path) lets any screen in the chain pop all the
/// way back to Start after a terminal action (e.g. a successful Voice generation)
/// without needing to know how many screens are actually on the stack.
public enum CreateFlowRoute: Hashable, Sendable {
    case occasionSelection
    case form
    case wishes
    case create
    case voice
    case videoCard
}
