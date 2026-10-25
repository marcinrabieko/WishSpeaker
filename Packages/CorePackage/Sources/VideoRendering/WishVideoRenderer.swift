import ffmpegkit
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.wishspeaker.app", category: "VideoRendering")

public struct WishVideoRenderRequest: Sendable {
    public let audioURL: URL
    public let words: [VideoWordTiming]
    public let theme: VideoTheme
    public let outputURL: URL

    public init(audioURL: URL, words: [VideoWordTiming], theme: VideoTheme, outputURL: URL) {
        self.audioURL = audioURL
        self.words = words
        self.theme = theme
        self.outputURL = outputURL
    }
}

public enum WishVideoRenderError: Error, LocalizedError {
    case missingAsset(String)
    case ffmpegFailed(String)

    public var errorDescription: String? {
        switch self {
        case .missingAsset(let name):
            "Missing video asset: \(name)"
        case .ffmpegFailed(let output):
            "ffmpeg failed: \(output)"
        }
    }
}

/// Renders the narrated greeting-card video on device — a port of the backend's
/// `render_wish_video()` (WishSpeaker-Backend services/video_service.py): looping
/// themed background + themed card border + libass-burned wish text + narration,
/// followed by a fixed-length outro image, all in a single ffmpeg filtergraph.
///
/// The only deliberate deviation from the backend is the encoder: `h264_videotoolbox`
/// (hardware) instead of `libx264`, which is far faster on device and keeps the
/// ffmpeg build LGPL. Assets (backgrounds, borders, outro, font) are resolved from
/// `VideoRendering/Assets/` by the backend's own file names.
public enum WishVideoRenderer {
    static let canvasSize = 1024
    static let fps = 30
    static let videoBitrate = "5M"
    static let audioDelayMs = 1000
    static let outroDurationSeconds = 4.0
    static let outroSoundDelayMs = 1500
    static let crossfadeDurationSeconds = 0.6

    private static let outroImageFileName = "outro.png"
    private static let outroSoundFileName = "outro_sound.mp3"
    private static let fontFileName = "LibreBaskerville-Regular.ttf"

    public static func render(_ request: WishVideoRenderRequest) async throws {
        try await Task.detached(priority: .userInitiated) {
            try renderSync(request)
        }.value
    }

    private static func renderSync(_ request: WishVideoRenderRequest) throws {
        let backgroundURL = try assetURL(request.theme.backgroundFileName)
        let borderURL = try assetURL(request.theme.borderFileName)
        let outroImageURL = try assetURL(outroImageFileName)
        let outroSoundURL = try assetURL(outroSoundFileName)
        let fontURL = try assetURL(fontFileName)

        // The text stays on screen right up to the main clip's last frame, so the
        // main clip's length is driven by the last spoken word plus the same holds
        // the subtitle script uses.
        let lastWordEndMs = request.words.last?.endMs ?? 0
        let mainDurationMs = audioDelayMs
            + lastWordEndMs
            + SubtitleScript.pageCrossfadeMs
            + SubtitleScript.pageEndHoldMs
            + SubtitleScript.finalPageExtraHoldMs
        let layout = VideoLayout(canvasSize: canvasSize)

        let workDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("video_render_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: workDirectory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: workDirectory)
        }

        let subtitlesURL = workDirectory.appendingPathComponent("subtitles.ass")
        let subtitles = SubtitleScript.make(words: request.words, mainDurationMs: mainDurationMs, layout: layout)
        try subtitles.write(to: subtitlesURL, atomically: true, encoding: .utf8)

        let filterComplex = makeFilterComplex(
            mainDurationSeconds: Double(mainDurationMs) / 1000.0,
            layout: layout,
            subtitlesPath: subtitlesURL.path,
            fontsDirectory: fontURL.deletingLastPathComponent().path
        )

        let arguments = [
            "-hide_banner",
            "-stream_loop", "-1",
            "-i", backgroundURL.path,
            "-i", borderURL.path,
            "-i", request.audioURL.path,
            "-loop", "1",
            "-i", outroImageURL.path,
            "-i", outroSoundURL.path,
            "-filter_complex", filterComplex,
            "-map", "[v]",
            "-map", "[a]",
            "-c:v", "h264_videotoolbox",
            "-b:v", videoBitrate,
            "-pix_fmt", "yuv420p",
            "-c:a", "aac",
            "-b:a", "192k",
            "-y",
            request.outputURL.path
        ]

        let startedAt = Date()
        let session = FFmpegKit.execute(withArguments: arguments)

        guard let session, ReturnCode.isSuccess(session.getReturnCode()) else {
            let output = session?.getOutput() ?? "no session"
            logger.error("render failed:\n\(output, privacy: .public)")
            throw WishVideoRenderError.ffmpegFailed(String(output.suffix(600)))
        }

        logger.info("render finished in \(Date().timeIntervalSince(startedAt), format: .fixed(precision: 2))s")
    }

    private static func makeFilterComplex(
        mainDurationSeconds: Double,
        layout: VideoLayout,
        subtitlesPath: String,
        fontsDirectory: String
    ) -> String {
        let size = layout.canvasSize
        let cardSize = layout.cardSize
        let cardOffset = layout.cardOffset
        let crossfadeOffset = max(0.0, mainDurationSeconds - crossfadeDurationSeconds)
        let squareCrop = "scale=\(size):\(size):force_original_aspect_ratio=increase,crop=\(size):\(size)"

        return [
            "[0:v]trim=duration=\(mainDurationSeconds),setpts=PTS-STARTPTS,\(squareCrop)[bg]",
            "[1:v]scale=\(cardSize):\(cardSize)[border]",
            "[bg][border]overlay=\(cardOffset):\(cardOffset):format=auto,"
                + "subtitles='\(subtitlesPath)':fontsdir='\(fontsDirectory)',fps=\(fps)[mainv]",
            "[2:a]adelay=\(audioDelayMs)|\(audioDelayMs),atrim=duration=\(mainDurationSeconds),asetpts=PTS-STARTPTS[maina]",
            "[3:v]\(squareCrop),fps=\(fps),trim=duration=\(outroDurationSeconds),setpts=PTS-STARTPTS[outrov]",
            "[4:a]adelay=\(outroSoundDelayMs)|\(outroSoundDelayMs),apad,"
                + "atrim=duration=\(outroDurationSeconds),asetpts=PTS-STARTPTS[outroa]",
            "[mainv][outrov]xfade=transition=fade:duration=\(crossfadeDurationSeconds):offset=\(crossfadeOffset)[v]",
            "[maina][outroa]acrossfade=d=\(crossfadeDurationSeconds)[a]"
        ].joined(separator: ";")
    }

    private static func assetURL(_ fileName: String) throws -> URL {
        let url = Bundle.module.bundleURL
            .appendingPathComponent("Assets")
            .appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw WishVideoRenderError.missingAsset(fileName)
        }

        return url
    }
}
