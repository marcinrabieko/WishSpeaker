import Foundation

public extension VideoAsset {
    /// Resolves `videoFileReference` to a playable file URL, checking the app's
    /// Documents directory first (where generated videos are saved) and falling back
    /// to `nil` if nothing exists yet.
    var videoURL: URL? {
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
    /// `nil` when there's no reference at all, or when the referenced file is missing.
    var thumbnailURL: URL? {
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
