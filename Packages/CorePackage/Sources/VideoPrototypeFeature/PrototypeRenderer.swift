import AVFoundation
import CoreGraphics
import CoreText
import Foundation
import os
import UIKit

private let logger = Logger(subsystem: "com.wishspeaker.app", category: "VideoPrototype")

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
        logger.info("renderBasicClip: starting, duration=\(durationSeconds, format: .fixed(precision: 1))s")
        let totalStart = CFAbsoluteTimeGetCurrent()

        let assets = try loadAssets()
        registerFontIfNeeded(fontURL: assets.fontURL)
        logger.info("renderBasicClip: assets loaded + font registered")

        let compositionStart = CFAbsoluteTimeGetCurrent()

        let background = try await loadBackground(url: assets.backgroundURL)
        logger.info("renderBasicClip: background track loaded, naturalSize=\(background.naturalSize.width, format: .fixed(precision: 0))x\(background.naturalSize.height, format: .fixed(precision: 0)), duration=\(background.duration, format: .fixed(precision: 2))s")
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("prototype_\(UUID().uuidString)")
            .appendingPathExtension("mp4")
        let writerSetup = try makeWriter(outputURL: outputURL)
        logger.info("renderBasicClip: AVAssetWriter configured, output=\(outputURL.lastPathComponent)")

        let renderStart = CFAbsoluteTimeGetCurrent()

        let decodedFrames = try decodeFrames(asset: background.asset, track: background.track)
        logger.info("renderBasicClip: decoded \(decodedFrames.count) background frames in \(CFAbsoluteTimeGetCurrent() - renderStart, format: .fixed(precision: 2))s")

        let prescaleStart = CFAbsoluteTimeGetCurrent()
        let backgroundFrames = prerenderBackgroundFrames(decodedFrames, naturalSize: background.naturalSize, canvasSize: canvasSize)
        let borderRenderSize = CGFloat(canvasSize) * 0.82
        let borderOffset = (CGFloat(canvasSize) - borderRenderSize) / 2
        let prerenderedBorder = prerenderBorder(assets.borderCGImage, canvasSize: canvasSize, renderSize: borderRenderSize, offset: borderOffset)
        logger.info("renderBasicClip: pre-scaled \(backgroundFrames.count) background frames + border in \(CFAbsoluteTimeGetCurrent() - prescaleStart, format: .fixed(precision: 2))s")

        guard let pixelBufferPool = writerSetup.adaptor.pixelBufferPool else {
            throw RendererError.pixelBufferPoolUnavailable
        }

        let textImage = makeTextImage(text, canvasSize: canvasSize)
        logger.info("renderBasicClip: text image built (nil=\(textImage == nil))")

        // Flattens border + text into ONE alpha-blended layer up front, instead of
        // leaving the render loop to alpha-composite them as two separate context.draw
        // calls per frame. On-device measurement found drawBorder+drawText alone
        // costing ~31s of a 450-frame loop even after both were already same-size
        // blits (no resampling) — alpha compositing itself, not resampling, is the
        // remaining per-call cost CGContext.draw() pays, and merging two layers into
        // one halves how many times that cost is paid per frame.
        let overlayImage = flattenOverlay(border: prerenderedBorder, text: textImage, canvasSize: canvasSize)

        let job = RenderJob(
            durationSeconds: durationSeconds,
            backgroundFrames: backgroundFrames,
            overlayImage: overlayImage,
            pixelBufferPool: pixelBufferPool,
            writer: writerSetup.writer,
            writerInput: writerSetup.writerInput,
            adaptor: writerSetup.adaptor,
            backgroundDuration: background.duration
        )
        logger.info("renderBasicClip: entering frame render loop, totalFrames=\(Int((durationSeconds * Double(fps)).rounded(.up)))")
        try await renderFrames(job)

        let renderEnd = CFAbsoluteTimeGetCurrent()
        logger.info("renderBasicClip: frame render loop finished in \(renderEnd - renderStart, format: .fixed(precision: 2))s, finishing writer")

        writerSetup.writerInput.markAsFinished()
        await writerSetup.writer.finishWriting()

        let writeFinishEnd = CFAbsoluteTimeGetCurrent()
        logger.info("renderBasicClip: writer finished in \(writeFinishEnd - renderEnd, format: .fixed(precision: 2))s, status=\(writerSetup.writer.status.rawValue)")

        if writerSetup.writer.status != .completed {
            throw RendererError.writerFailed(writerSetup.writer.error?.localizedDescription ?? "writer.status = \(writerSetup.writer.status.rawValue)")
        }

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int64) ?? 0
        logger.info("renderBasicClip: done, total=\(writeFinishEnd - totalStart, format: .fixed(precision: 2))s, fileSize=\(fileSize) bytes")

        return Result(
            outputURL: outputURL,
            totalDuration: writeFinishEnd - totalStart,
            compositionDuration: renderStart - compositionStart,
            renderDuration: renderEnd - renderStart,
            writeFinishDuration: writeFinishEnd - renderEnd,
            fileSizeBytes: fileSize
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
        /// Already scaled/cropped to exactly canvasSize×canvasSize — see
        /// prerenderBackgroundFrames. The render loop blits these 1:1, no resampling.
        let backgroundFrames: [CGImage]
        /// Border + text flattened into one alpha-blended canvasSize×canvasSize image
        /// — see flattenOverlay. The render loop composites this once per frame
        /// instead of compositing border and text as two separate alpha-blends.
        let overlayImage: CGImage?
        let pixelBufferPool: CVPixelBufferPool
        let writer: AVAssetWriter
        let writerInput: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
        let backgroundDuration: Double
    }

    private struct FrameTimings {
        var pixelBufferCreate: Double = 0
        var contextCreate: Double = 0
        var drawBackground: Double = 0
        var drawOverlay: Double = 0
        var append: Double = 0
        var wait: Double = 0
    }

    /// Shared context needed to render any single frame — kept as a struct for the
    /// same function_parameter_count reason as RenderJob.
    private struct FrameContext {
        let job: RenderJob
        let colorSpace: CGColorSpace
        let bitmapInfo: UInt32
        let fullCanvasRect: CGRect
        let frameDuration: CMTime
    }

    private static func renderFrames(_ job: RenderJob) async throws {
        let frameContext = FrameContext(
            job: job,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue,
            fullCanvasRect: CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize),
            frameDuration: CMTime(value: 1, timescale: fps)
        )
        let totalFrames = Int((job.durationSeconds * Double(fps)).rounded(.up))

        var timings = FrameTimings()
        let loopStart = CFAbsoluteTimeGetCurrent()

        for frameIndex in 0..<totalFrames {
            try await renderSingleFrame(frameIndex, context: frameContext, timings: &timings)

            if frameIndex % 30 == 0 {
                logger.info("renderFrames: frame \(frameIndex)/\(totalFrames), elapsed=\(CFAbsoluteTimeGetCurrent() - loopStart, format: .fixed(precision: 2))s")
            }
        }

        logger.info("""
        renderFrames breakdown over \(totalFrames) frames: \
        wait=\(timings.wait, format: .fixed(precision: 2))s \
        pixelBufferCreate=\(timings.pixelBufferCreate, format: .fixed(precision: 2))s \
        contextCreate=\(timings.contextCreate, format: .fixed(precision: 2))s \
        drawBackground=\(timings.drawBackground, format: .fixed(precision: 2))s \
        drawOverlay=\(timings.drawOverlay, format: .fixed(precision: 2))s \
        append=\(timings.append, format: .fixed(precision: 2))s
        """)
    }

    private static func renderSingleFrame(_ frameIndex: Int, context frameContext: FrameContext, timings: inout FrameTimings) async throws {
        let job = frameContext.job

        var t = CFAbsoluteTimeGetCurrent()
        while !job.writerInput.isReadyForMoreMediaData {
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        timings.wait += CFAbsoluteTimeGetCurrent() - t

        t = CFAbsoluteTimeGetCurrent()
        var pixelBufferOut: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(nil, job.pixelBufferPool, &pixelBufferOut)
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOut else {
            throw RendererError.pixelBufferCreationFailed
        }
        timings.pixelBufferCreate += CFAbsoluteTimeGetCurrent() - t

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        }

        t = CFAbsoluteTimeGetCurrent()
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: canvasSize,
            height: canvasSize,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: frameContext.colorSpace,
            bitmapInfo: frameContext.bitmapInfo
        ) else {
            throw RendererError.pixelBufferCreationFailed
        }
        timings.contextCreate += CFAbsoluteTimeGetCurrent() - t

        // Background: loop by wall-clock time against the source clip's own frame
        // rate, matching ffmpeg's -stream_loop -1 semantics (re-reading from the
        // start once the source is exhausted) rather than freezing on the last frame.
        let elapsedSeconds = Double(frameIndex) / Double(fps)
        let loopedSeconds = elapsedSeconds.truncatingRemainder(dividingBy: job.backgroundDuration)
        let sourceFrameIndex = min(
            Int((loopedSeconds / job.backgroundDuration) * Double(job.backgroundFrames.count)),
            job.backgroundFrames.count - 1
        )
        let backgroundImage = job.backgroundFrames[sourceFrameIndex]

        // Both layers are already pre-scaled to exactly canvasSize×canvasSize (see
        // prerenderBackgroundFrames/flattenOverlay) — same-size blits, not resampling
        // scales. The background draw has no alpha to blend (cheap); the overlay draw
        // is the one alpha-composite per frame, down from two.
        t = CFAbsoluteTimeGetCurrent()
        context.draw(backgroundImage, in: frameContext.fullCanvasRect)
        timings.drawBackground += CFAbsoluteTimeGetCurrent() - t

        t = CFAbsoluteTimeGetCurrent()
        if let overlayImage = job.overlayImage {
            context.draw(overlayImage, in: frameContext.fullCanvasRect)
        }
        timings.drawOverlay += CFAbsoluteTimeGetCurrent() - t

        t = CFAbsoluteTimeGetCurrent()
        let presentationTime = CMTimeMultiply(frameContext.frameDuration, multiplier: Int32(frameIndex))
        if !job.adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
            throw RendererError.writerFailed(job.writer.error?.localizedDescription ?? "adaptor.append failed at frame \(frameIndex)")
        }
        timings.append += CFAbsoluteTimeGetCurrent() - t
    }

    private static func cgImage(from pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
}
