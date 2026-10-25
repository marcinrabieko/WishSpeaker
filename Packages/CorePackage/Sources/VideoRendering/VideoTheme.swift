import Foundation

/// Border + background pair a wish video is rendered with. Mirrors the backend's
/// THEME_BORDERS/THEME_BACKGROUNDS maps (WishSpeaker-Backend services/video_service.py),
/// including the asset file names, so the same asset files can be dropped into
/// `VideoRendering/Assets/` unchanged.
public enum VideoTheme: String, CaseIterable, Sendable {
    case celebration
    case romantic
    case wedding
    case floral
    case calm
    case classic

    var borderFileName: String {
        "border_\(rawValue).png"
    }

    var backgroundFileName: String {
        "background_\(rawValue)_normalized.mp4"
    }
}
