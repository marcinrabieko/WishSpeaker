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

    /// The occasion headline above the first page's wish text — a title, not a shout,
    /// so only ~12.5% larger than the wish text itself.
    var greetingFontSize: Int {
        scaled(72.0)
    }

    var greetingCenterY: Int {
        textMarginTop + greetingFontSize / 2 + Int((20.0 * canvasScale).rounded())
    }

    /// How far the first page's wish text is pushed down to make room for the headline.
    /// Not scaled by `cardScale` — the backend froze it at its old 1080px value, so
    /// retuning the headline's font size never moves the wish text.
    var titlePageTextCenterY: Int {
        textCenterY + Int((44.0 * canvasScale).rounded())
    }

    private func scaled(_ value: Double) -> Int {
        Int((value * Self.cardScale * canvasScale).rounded())
    }
}
