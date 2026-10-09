import Foundation

public extension VoiceAsset {
    /// Resolves `audioFileReference` to a playable file URL. `bundledAudioURL`, when
    /// set, wins outright — a demo VoiceAsset's file lives in the app bundle, not
    /// Documents, so there's nothing to look up there. Otherwise checks the app's
    /// Documents directory (where generated voice recordings are saved) and falls
    /// back to `nil` if nothing exists yet — e.g. a Library preview/example whose
    /// audio hasn't been recorded for the current language.
    var audioURL: URL? {
        if let bundledAudioURL {
            return bundledAudioURL
        }

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
