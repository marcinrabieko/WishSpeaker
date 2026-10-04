import Foundation

/// The 6 languages the backend has a dedicated prompt for (see
/// WishSpeaker-Backend/services/prompts/). Falls back to English for anything else.
enum SupportedLanguage: String {
    case en, pl, de, fr, it, es

    static var current: SupportedLanguage {
        guard let languageCode = Locale.current.language.languageCode?.identifier else {
            return .en
        }

        return SupportedLanguage(rawValue: languageCode) ?? .en
    }
}
