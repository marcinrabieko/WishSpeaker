import Foundation

public extension VoiceAsset {
    /// Resolves `audioFileReference` to a playable file URL, checking the app's
    /// Documents directory first (where generated voice recordings are saved) and
    /// falling back to `nil` if nothing exists yet — e.g. a Library preview/example
    /// whose audio hasn't been recorded for the current language.
    var audioURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsDirectory.appendingPathComponent(audioFileReference)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }
}
