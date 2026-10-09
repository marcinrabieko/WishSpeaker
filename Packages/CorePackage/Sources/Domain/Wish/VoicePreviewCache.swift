import CryptoKit
import Foundation

/// Caches remote voice-preview audio (ElevenLabs sample clips, played from
/// VoicePreviewPlayer on the Voice/Video narrator picker) to disk — persists across
/// app launches, unlike VoiceMetadataCache's in-memory catalog, since the audio bytes
/// themselves never change for a given provider URL and are worth keeping even after
/// the process restarts. The first play of a given preview downloads and saves it;
/// every subsequent play (same session or a later one) resolves straight to the local
/// file, no network request.
public actor VoicePreviewCache {
    public static let shared = VoicePreviewCache()

    private let urlSession: URLSession
    private var inFlightDownloads: [URL: Task<URL, Error>] = [:]

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    /// Resolves `remoteURL` to a local file URL, downloading and caching it on first
    /// use. Returns `remoteURL` itself if the download fails — playback then falls
    /// back to AVPlayer's normal streaming behavior instead of being blocked entirely
    /// by a transient network error.
    public func localURL(for remoteURL: URL) async -> URL {
        let cachedPath = cachedFileURL(for: remoteURL)

        if FileManager.default.fileExists(atPath: cachedPath.path) {
            return cachedPath
        }

        if let existingDownload = inFlightDownloads[remoteURL] {
            return (try? await existingDownload.value) ?? remoteURL
        }

        let downloadTask = Task<URL, Error> {
            let (tempFileURL, _) = try await urlSession.download(from: remoteURL)
            try FileManager.default.createDirectory(
                at: cachedPath.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            // Download tasks hand back a temp file in a location the system clears
            // on its own schedule — move, not copy, into the persistent cache
            // directory so the bytes survive until this cache evicts them itself.
            if FileManager.default.fileExists(atPath: cachedPath.path) {
                try FileManager.default.removeItem(at: cachedPath)
            }
            try FileManager.default.moveItem(at: tempFileURL, to: cachedPath)
            return cachedPath
        }

        inFlightDownloads[remoteURL] = downloadTask

        defer {
            inFlightDownloads[remoteURL] = nil
        }

        return (try? await downloadTask.value) ?? remoteURL
    }

    /// Deterministic file name from the remote URL's own hash — same URL always
    /// resolves to the same cache entry, so a second app launch finds what the first
    /// one downloaded without needing to persist a lookup table separately.
    private func cachedFileURL(for remoteURL: URL) -> URL {
        let digest = SHA256.hash(data: Data(remoteURL.absoluteString.utf8))
        let fileName = digest.map { String(format: "%02x", $0) }.joined()

        return cacheDirectory.appendingPathComponent(fileName).appendingPathExtension("mp3")
    }

    private var cacheDirectory: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return caches.appendingPathComponent("VoicePreviews", isDirectory: true)
    }
}
