import CoreGraphics
import CoreText
import Foundation
import UIKit

/// Layer pre-rendering helpers for PrototypeRenderer, split into their own file purely
/// to stay under SwiftLint's type_body_length — see PrototypeRenderer.swift for the
/// actual render pipeline these feed into.
extension PrototypeRenderer {
    /// Scales+crops every decoded background frame to EXACTLY canvasSize×canvasSize
    /// once (601 times for the celebration theme), instead of leaving that resampling
    /// for context.draw() to redo on every one of the 450 frames in a 15s render loop.
    /// On-device measurement (see renderFrames' timing breakdown) found context.draw()
    /// doing this scale-on-every-call was ~82s of a ~155s total render — CGContext's
    /// draw(_:in:) does real resampling work per call when the destination rect's size
    /// differs from the source CGImage's pixel size, it does not cache that work
    /// itself. Pre-scaling once here means the render loop's context.draw() call is a
    /// same-size blit (no resampling), which is what makes it cheap.
    static func prerenderBackgroundFrames(_ frames: [CGImage], naturalSize: CGSize, canvasSize: Int) -> [CGImage] {
        let canvas = CGFloat(canvasSize)
        let scale = max(canvas / naturalSize.width, canvas / naturalSize.height)
        let scaledWidth = naturalSize.width * scale
        let scaledHeight = naturalSize.height * scale
        let originX = (canvas - scaledWidth) / 2
        let originY = (canvas - scaledHeight) / 2
        let drawRect = CGRect(x: originX, y: originY, width: scaledWidth, height: scaledHeight)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        return frames.compactMap { frame in
            guard let context = CGContext(
                data: nil,
                width: canvasSize,
                height: canvasSize,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                return nil
            }
            context.draw(frame, in: drawRect)
            return context.makeImage()
        }
    }

    /// Same pre-scale-once rationale as prerenderBackgroundFrames, applied to the
    /// single border image — scales it to its final on-canvas size exactly once and
    /// bakes in the canvas-relative position, so the render loop's composite is a
    /// same-size, same-position blit instead of a per-frame scale.
    static func prerenderBorder(_ image: CGImage, canvasSize: Int, renderSize: CGFloat, offset: CGFloat) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        guard let context = CGContext(
            data: nil,
            width: canvasSize,
            height: canvasSize,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        context.draw(image, in: CGRect(x: offset, y: offset, width: renderSize, height: renderSize))
        return context.makeImage()
    }

    /// Composites border + text (each already a full canvasSize×canvasSize image, see
    /// prerenderBorder/makeTextImage) into a single alpha-blended layer once, so the
    /// render loop pays the cost of alpha compositing onto the background only once per
    /// frame instead of twice.
    static func flattenOverlay(border: CGImage?, text: CGImage?, canvasSize: Int) -> CGImage? {
        guard border != nil || text != nil else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let fullRect = CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize)

        guard let context = CGContext(
            data: nil,
            width: canvasSize,
            height: canvasSize,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        if let border {
            context.draw(border, in: fullRect)
        }
        if let text {
            context.draw(text, in: fullRect)
        }
        return context.makeImage()
    }

    /// Pre-renders the text block to a CGImage ONCE per render (not once per frame —
    /// text is static for the whole clip in this Stage 1 prototype) via
    /// UIGraphicsImageRenderer, then composited the same way as the background/border
    /// (plain context.draw). Two reasons this replaced a direct CoreText
    /// CTFrameDraw-into-the-pixel-buffer-context approach:
    /// 1. Performance: building font/framesetter/CTFrame 450+ times (once per video
    ///    frame at 30fps for a 15s clip) was the dominant cost behind an initial
    ///    on-device measurement of 0.10x realtime.
    /// 2. Correctness: UIGraphicsImageRenderer has UIKit's well-defined top-left-origin,
    ///    Y-down coordinate space baked in — drawing text there and compositing the
    ///    resulting CGImage with the same context.draw already used for background/
    ///    border (which render right-side-up) sidesteps the question of which
    ///    direction to flip CoreText's PDF-style bottom-left-origin text matrix inside
    ///    a CVPixelBuffer-backed CGContext — manually getting that flip's sign wrong
    ///    is exactly what produced upside-down, mirrored text in the first on-device
    ///    test.
    static func makeTextImage(_ text: String, canvasSize: Int) -> CGImage? {
        let fontSize: CGFloat = 52 // Stage 1: fixed size, matches backend's FONT_SIZE scaled proportionally to 1024 canvas.
        guard let font = UIFont(name: "Libre Baskerville", size: fontSize) else {
            return nil
        }

        let textColor = UIColor(red: 0x17 / 255, green: 0x14 / 255, blue: 0x12 / 255, alpha: 1)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let canvas = CGFloat(canvasSize)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvas, height: canvas), format: format)

        let image = renderer.image { _ in
            let textAreaWidth = canvas * 0.7
            let boundingSize = CGSize(width: textAreaWidth, height: canvas * 0.4)
            let textSize = (text as NSString).boundingRect(
                with: boundingSize,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            ).size
            let drawRect = CGRect(
                x: (canvas - textAreaWidth) / 2,
                y: (canvas - textSize.height) / 2,
                width: textAreaWidth,
                height: textSize.height
            )
            (text as NSString).draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        }

        return image.cgImage
    }

    static func registerFontIfNeeded(fontURL: URL) {
        guard UIFont(name: "Libre Baskerville", size: 12) == nil else {
            return
        }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }
}
