import Foundation

/// Pixel geometry of the rendered video. Every base value below is the backend's,
/// tuned there at a 1080px canvas, so each one is scaled by `canvasSize / 1080`.
struct VideoLayout {
    static let cardScale = 0.82

    let canvasSize: Int

    private var canvasScale: Double {
        Double(canvasSize) / 1080.0
    }

    var cardSize: Int {
        Int((Double(canvasSize) * Self.cardScale).rounded())
    }

    var cardOffset: Int {
        (canvasSize - cardSize) / 2
    }

    var fontSize: Int {
        scaled(64.0)
    }

    var lineSpacing: Int {
        scaled(6.0)
    }

    var textMarginX: Int {
        cardOffset + scaled(90.0)
    }

    var textMarginTop: Int {
        cardOffset + scaled(210.0)
    }

    var textMarginBottom: Int {
        cardOffset + scaled(230.0)
    }

    var textCenterX: Int {
        canvasSize / 2
    }

    var textCenterY: Int {
        textMarginTop + (canvasSize - textMarginTop - textMarginBottom) / 2
    }

    private func scaled(_ value: Double) -> Int {
        Int((value * Self.cardScale * canvasScale).rounded())
    }
}
