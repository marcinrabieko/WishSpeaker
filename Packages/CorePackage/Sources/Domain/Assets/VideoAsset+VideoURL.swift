import Foundation

public extension VideoAsset {
    /// Resolves `videoFileReference` to a playable file URL. `bundledVideoURL`, when
    /// set, wins outright — a demo VideoAsset's file lives in the app bundle, not
    /// Documents, so there's nothing to look up there. Otherwise checks the app's
    /// Documents directory (where generated videos are saved) and falls back to `nil`
    /// if nothing exists yet.
    var videoURL: URL? {
        if let bundledVideoURL {
            return bundledVideoURL
        }

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsDirectory.appendingPathComponent(videoFileReference)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }

    /// Resolves `thumbnailReference` to a file URL the same way `videoURL` does —
    /// `bundledThumbnailURL` wins outright when set, otherwise `nil` when there's no
    /// reference at all, or when the referenced file is missing.
    var thumbnailURL: URL? {
        if let bundledThumbnailURL {
            return bundledThumbnailURL
        }

        guard let thumbnailReference else {
            return nil
        }

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsDirectory.appendingPathComponent(thumbnailReference)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }
}
