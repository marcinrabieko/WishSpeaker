import Foundation

/// A step in the Start → Occasion → Form → Wishes → Create flow, pushed onto the shared
/// NavigationPath owned by the app's root NavigationStack. Voice/Video generation is not
/// a route on this path — WishResultView (the `.create` destination) reaches VoiceView/
/// VideoView through its own local `navigationDestination(isPresented:)` instead, the
/// same way LibraryFeature's WishResultView(wish:) does.
public enum CreateFlowRoute: Hashable, Sendable {
    case occasionSelection
    case form
    case wishes
    case create
}
