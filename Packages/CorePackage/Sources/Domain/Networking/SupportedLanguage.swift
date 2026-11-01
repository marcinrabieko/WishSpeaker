import Foundation

/// The app is English-only, so wishes are always generated in English regardless of the
/// device locale. The backend also has prompts for pl/de/fr/it/es (see
/// WishSpeaker-Backend/services/prompts/), but the app deliberately doesn't use them.
enum SupportedLanguage: String {
    case en

    static var current: SupportedLanguage { .en }
}
