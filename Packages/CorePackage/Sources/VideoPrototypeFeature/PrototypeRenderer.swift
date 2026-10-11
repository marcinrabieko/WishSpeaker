import AVFoundation
import CoreGraphics
import CoreText
import Foundation
import UIKit

/// Standalone native iOS video renderer prototype — draws every frame manually via
/// Core Graphics into a CVPixelBuffer and encodes through AVAssetWriter (which uses
/// VideoToolbox's hardware H.264 encoder under the hood on real devices), rather than
/// going through AVVideoCompositionCoreAnimationTool. Chosen over Core Animation
/// because this pipeline needs frame-exact control over multi-segment subtitle
/// fade-in/fade-out timing (mirroring the backend's ASS Dialogue Start/End semantics)
/// that would otherwise require fragile, hard-to-verify stacks of overlapping
/// CALayer opacity animations.
///
/// This is Stage 1 of the prototype: background video (looped/trimmed) + border PNG
/// overlay + ONE static centered text block, no word-level subtitle paging, no outro,
/// no crossfade yet. Purpose is solely to verify the AVAssetWriter + VideoToolbox
/// pipeline actually produces a valid 1024x1024/30fps/H.264 MP4 on a physical device
/// before investing in the full ASS-equivalent text system.
public enum PrototypeRenderer {
    public struct Result: Sendable {
        public let outputURL: URL
        public let totalDuration: TimeInterval
        public let compositionDuration: TimeInterval
        public let renderDuration: TimeInterval
        public let writeFinishDuration: TimeInterval
        public let fileSizeBytes: Int64
    }

    public enum RendererError: Error, LocalizedError {
        case assetNotFound(String)
        case noVideoTrack
        case pixelBufferPoolUnavailable
        case pixelBufferCreationFailed
        case writerFailed(String)

        public var errorDescription: String? {
            switch self {
            case .assetNotFound(let name):
                return "Prototype asset not found: \(name)"
            case .noVideoTrack:
                return "Background video has no video track"
            case .pixelBufferPoolUnavailable:
                return "AVAssetWriterInputPixelBufferAdaptor has no pixel buffer pool"
            case .pixelBufferCreationFailed:
                return "Failed to create a CVPixelBuffer for a frame"
            case .writerFailed(let reason):
                return "AVAssetWriter failed: \(reason)"
            }
        }
    }

    public static let canvasSize = 1024
    public static let fps: Int32 = 30

    /// Renders a single clip: looped background + border overlay + one static,
    /// full-duration centered text block. `durationSeconds` controls how long the
    /// output video is (used by the benchmark to produce 15s/30s/60s test clips).
    public static func renderBasicClip(durationSeconds: Double, text: String) async throws -> Result {
        let totalStart = CFAbsoluteTimeGetCurrent()

        let assets = try loadAssets()
        registerFontIfNeeded(fontURL: assets.fontURL)

        let compositionStart = CFAbsoluteTimeGetCurrent()

        let background = try await loadBackground(url: assets.backgroundURL)
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("prototype_\(UUID().uuidString)")
            .appendingPathExtension("mp4")
        let writerSetup = try makeWriter(outputURL: outputURL)

        let renderStart = CFAbsoluteTimeGetCurrent()

        let backgroundFrames = try decodeFrames(asset: background.asset, track: background.track)
        guard let pixelBufferPool = writerSetup.adaptor.pixelBufferPool else {
            throw RendererError.pixelBufferPoolUnavailable
        }

        let job = RenderJob(
            durationSeconds: durationSeconds,
            text: text,
            backgroundFrames: backgroundFrames,
            backgroundNaturalSize: background.naturalSize,
            backgroundDuration: background.duration,
            borderCGImage: assets.borderCGImage,
            fontURL: assets.fontURL,
            pixelBufferPool: pixelBufferPool,
            writer: writerSetup.writer,
            writerInput: writerSetup.writerInput,
            adaptor: writerSetup.adaptor
        )
        try await renderFrames(job)

        let renderEnd = CFAbsoluteTimeGetCurrent()

        writerSetup.writerInput.markAsFinished()
        await writerSetup.writer.finishWriting()

        let writeFinishEnd = CFAbsoluteTimeGetCurrent()

        if writerSetup.writer.status != .completed {
            throw RendererError.writerFailed(writerSetup.writer.error?.localizedDescription ?? "writer.status = \(writerSetup.writer.status.rawValue)")
        }

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int64) ?? 0

        return Result(
            outputURL: outputURL,
            totalDuration: writeFinishEnd - totalStart,
            compositionDuration: renderStart - compositionStart,
            renderDuration: renderEnd - renderStart,
            writeFinishDuration: writeFinishEnd - renderEnd,
            fileSizeBytes: fileSize ?? 0
        )
    }

    // MARK: - Setup helpers

    private struct LoadedAssets {
        let backgroundURL: URL
        let borderCGImage: CGImage
        let fontURL: URL
    }

    private static func loadAssets() throws -> LoadedAssets {
        guard let backgroundURL = Bundle.module.url(forResource: "background_celebration_normalized", withExtension: "mp4") else {
            throw RendererError.assetNotFound("background_celebration_normalized.mp4")
        }
        guard let borderURL = Bundle.module.url(forResource: "border_celebration", withExtension: "png") else {
            throw RendererError.assetNotFound("border_celebration.png")
        }
        guard let fontURL = Bundle.module.url(forResource: "LibreBaskerville-Regular", withExtension: "ttf") else {
            throw RendererError.assetNotFound("LibreBaskerville-Regular.ttf")
        }
        guard let borderCGImage = UIImage(contentsOfFile: borderURL.path)?.cgImage else {
            throw RendererError.assetNotFound("border_celebration.png (failed to decode)")
        }
        return LoadedAssets(backgroundURL: backgroundURL, borderCGImage: borderCGImage, fontURL: fontURL)
    }

    private struct LoadedBackground {
        let asset: AVURLAsset
        let track: AVAssetTrack
        let naturalSize: CGSize
        let duration: Double
    }

    private static func loadBackground(url: URL) async throws -> LoadedBackground {
        let asset = AVURLAsset(url: url)
        guard let track = try await asset.loadTracks(withMediaType: .video).first else {
            throw RendererError.noVideoTrack
        }
        let naturalSize = try await track.load(.naturalSize)
        let duration = try await asset.load(.duration).seconds
        return LoadedBackground(asset: asset, track: track, naturalSize: naturalSize, duration: duration)
    }

    private struct WriterSetup {
        let writer: AVAssetWriter
        let writerInput: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
    }

    private static func makeWriter(outputURL: URL) throws -> WriterSetup {
        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: canvasSize,
            AVVideoHeightKey: canvasSize,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                AVVideoExpectedSourceFrameRateKey: fps
            ]
        ]
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerInput.expectsMediaDataInRealTime = false

        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: canvasSize,
            kCVPixelBufferHeightKey as String: canvasSize,
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: pixelBufferAttributes
        )

        guard writer.canAdd(writerInput) else {
            throw RendererError.writerFailed("canAdd(writerInput) returned false")
        }
        writer.add(writerInput)

        guard writer.startWriting() else {
            throw RendererError.writerFailed(writer.error?.localizedDescription ?? "startWriting() returned false")
        }
        writer.startSession(atSourceTime: .zero)

        return WriterSetup(writer: writer, writerInput: writerInput, adaptor: adaptor)
    }

    /// Decodes the background clip's frames up front via AVAssetReader so the render
    /// loop can sample by wall-clock time without re-decoding per frame. Acceptable
    /// for a short, small (540x540) background loop in this prototype — would need
    /// streaming decode instead of full in-memory buffering for longer/larger sources.
    private static func decodeFrames(asset: AVURLAsset, track: AVAssetTrack) throws -> [CGImage] {
        let reader = try AVAssetReader(asset: asset)
        let readerOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: readerOutputSettings)
        reader.add(readerOutput)
        reader.startReading()

        var frames: [CGImage] = []
        while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
               let cgImage = Self.cgImage(from: imageBuffer) {
                frames.append(cgImage)
            }
        }
        reader.cancelReading()

        if frames.isEmpty {
            throw RendererError.noVideoTrack
        }
        return frames
    }

    // MARK: - Frame rendering loop

    /// Bundles every input renderFrames needs — kept as a single struct rather than a
    /// long parameter list (SwiftLint's function_parameter_count caps at 5).
    private struct RenderJob {
        let durationSeconds: Double
        let text: String
        let backgroundFrames: [CGImage]
        let backgroundNaturalSize: CGSize
        let backgroundDuration: Double
        let borderCGImage: CGImage
        let fontURL: URL
        let pixelBufferPool: CVPixelBufferPool
        let writer: AVAssetWriter
        let writerInput: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
    }

    private static func renderFrames(_ job: RenderJob) async throws {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let borderRenderSize = CGFloat(canvasSize) * 0.82
        let borderOffset = (CGFloat(canvasSize) - borderRenderSize) / 2
        let totalFrames = Int((job.durationSeconds * Double(fps)).rounded(.up))
        let frameDuration = CMTime(value: 1, timescale: fps)

        for frameIndex in 0..<totalFrames {
            while !job.writerInput.isReadyForMoreMediaData {
                try await Task.sleep(nanoseconds: 1_000_000)
            }

            var pixelBufferOut: CVPixelBuffer?
            let status = CVPixelBufferPoolCreatePixelBuffer(nil, job.pixelBufferPool, &pixelBufferOut)
            guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOut else {
                throw RendererError.pixelBufferCreationFailed
            }

            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            guard let context = CGContext(
                data: CVPixelBufferGetBaseAddress(pixelBuffer),
                width: canvasSize,
                height: canvasSize,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
                throw RendererError.pixelBufferCreationFailed
            }

            // Background: loop by wall-clock time against the source clip's own
            // frame rate, matching ffmpeg's -stream_loop -1 semantics (re-reading
            // from the start once the source is exhausted) rather than freezing on
            // the last frame.
            let elapsedSeconds = Double(frameIndex) / Double(fps)
            let loopedSeconds = elapsedSeconds.truncatingRemainder(dividingBy: job.backgroundDuration)
            let sourceFrameIndex = min(
                Int((loopedSeconds / job.backgroundDuration) * Double(job.backgroundFrames.count)),
                job.backgroundFrames.count - 1
            )
            let backgroundImage = job.backgroundFrames[sourceFrameIndex]

            drawBackground(backgroundImage, naturalSize: job.backgroundNaturalSize, in: context, canvasSize: canvasSize)
            drawBorder(job.borderCGImage, in: context, origin: CGPoint(x: borderOffset, y: borderOffset), size: borderRenderSize)
            drawCenteredText(job.text, in: context, canvasSize: canvasSize, fontURL: job.fontURL)

            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameIndex))
            if !job.adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                throw RendererError.writerFailed(job.writer.error?.localizedDescription ?? "adaptor.append failed at frame \(frameIndex)")
            }
        }
    }

    private static func cgImage(from pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        return context.createCGImage(ciImage, from: ciImage.extent)
    }

    private static func drawBackground(_ image: CGImage, naturalSize: CGSize, in context: CGContext, canvasSize: Int) {
        // Mirrors ffmpeg's scale=increase + crop: scale to COVER the canvas, then
        // center-crop — never letterbox/distort the background's aspect ratio.
        let canvas = CGFloat(canvasSize)
        let scale = max(canvas / naturalSize.width, canvas / naturalSize.height)
        let scaledWidth = naturalSize.width * scale
        let scaledHeight = naturalSize.height * scale
        let originX = (canvas - scaledWidth) / 2
        let originY = (canvas - scaledHeight) / 2
        // CGContext's Y axis is flipped relative to CVPixelBuffer's top-left video
        // convention here — draw in the context's native (bottom-left origin) space.
        context.draw(image, in: CGRect(x: originX, y: originY, width: scaledWidth, height: scaledHeight))
    }

    private static func drawBorder(_ image: CGImage, in context: CGContext, origin: CGPoint, size: CGFloat) {
        context.draw(image, in: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }

    private static func drawCenteredText(_ text: String, in context: CGContext, canvasSize: Int, fontURL: URL) {
        context.saveGState()
        // CGContext draws text with its own baseline-up coordinate convention that's
        // independent of the bitmap flip used for images above — flip just for text
        // so CoreText's top-down line layout matches on-screen expectations.
        context.textMatrix = .identity
        context.translateBy(x: 0, y: CGFloat(canvasSize))
        context.scaleBy(x: 1, y: -1)

        let fontSize: CGFloat = 52 // Stage 1: fixed size, matches backend's FONT_SIZE scaled proportionally to 1024 canvas.
        guard let font = CTFontCreateWithName("Libre Baskerville" as CFString, fontSize, nil) as CTFont? else {
            context.restoreGState()
            return
        }

        let textColor = CGColor(red: 0x17 / 255, green: 0x14 / 255, blue: 0x12 / 255, alpha: 1)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)

        let textAreaWidth = CGFloat(canvasSize) * 0.7
        let textAreaHeight = CGFloat(canvasSize) * 0.4
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter, CFRange(location: 0, length: 0), nil,
            CGSize(width: textAreaWidth, height: textAreaHeight), nil
        )

        let originX = (CGFloat(canvasSize) - suggestedSize.width) / 2
        let originY = (CGFloat(canvasSize) - suggestedSize.height) / 2
        let path = CGPath(rect: CGRect(x: originX, y: originY, width: suggestedSize.width, height: suggestedSize.height), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        CTFrameDraw(frame, context)

        context.restoreGState()
    }

    private static func registerFontIfNeeded(fontURL: URL) {
        guard UIFont(name: "Libre Baskerville", size: 12) == nil else {
            return
        }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }
}
