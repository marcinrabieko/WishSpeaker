import Foundation

public struct VideoWordTiming: Sendable, Hashable {
    public let text: String
    public let startMs: Int
    public let endMs: Int

    public init(text: String, startMs: Int, endMs: Int) {
        self.text = text
        self.startMs = startMs
        self.endMs = endMs
    }
}

/// Builds the ASS subtitle script burned into the video by libass — a port of the
/// backend's `_group_words_into_pages()` / `_generate_subtitle_ass()`. Each page is
/// plain static text (no karaoke highlight) crossfading into the next one; the last
/// page never fades out and stays on screen until the main clip's last frame.
enum SubtitleScript {
    static let maxCharsPerLine = 26
    static let maxLinesPerPage = 4
    static let pageCrossfadeMs = 400
    static let pageEndHoldMs = 400
    static let pageStartDelayMs = 100
    static let finalPageExtraHoldMs = 800

    private static let fontName = "Libre Baskerville"
    private static let textColor = "&H00121417"
    private static let softenTag = #"\blur1\bord0.5"#

    static func make(words: [VideoWordTiming], mainDurationMs: Int, layout: VideoLayout) -> String {
        let styleFormat = [
            "Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour,",
            "Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle,",
            "BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding"
        ].joined(separator: " ")
        let style = [
            "Default", fontName, "\(layout.fontSize)", textColor, textColor, textColor, "&H00000000",
            "0", "0", "0", "0", "100", "100", "0", "0", "1", "0", "0", "5",
            "\(layout.textMarginX)", "\(layout.textMarginX)", "\(layout.textMarginBottom)", "1"
        ].joined(separator: ",")

        let pages = groupIntoPages(words)
        let dialogueLines = pages.enumerated().map { index, pageWords in
            dialogue(
                pageWords: pageWords,
                isFirst: index == 0,
                isLast: index == pages.count - 1,
                mainDurationMs: mainDurationMs,
                layout: layout
            )
        }

        return """
        [Script Info]
        ScriptType: v4.00+
        PlayResX: \(layout.canvasSize)
        PlayResY: \(layout.canvasSize)

        [V4+ Styles]
        Format: \(styleFormat)
        Style: \(style)

        [Events]
        Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
        \(dialogueLines.joined(separator: "\n"))

        """
    }

    private static func dialogue(
        pageWords: [VideoWordTiming],
        isFirst: Bool,
        isLast: Bool,
        mainDurationMs: Int,
        layout: VideoLayout
    ) -> String {
        // The first page is visible from frame 0 (no fade-in), so the opening frame
        // (what a thumbnail captures) is never a blank card.
        let startMs = isFirst ? 0 : (pageWords.first?.startMs ?? 0) + pageStartDelayMs
        let endMs = isLast ? mainDurationMs : (pageWords.last?.endMs ?? 0) + pageCrossfadeMs + pageEndHoldMs
        let fadeInMs = isFirst ? 0 : pageCrossfadeMs
        let fadeOutMs = isLast ? 0 : pageCrossfadeMs

        let lines = wrapIntoLines(pageWords.map(\.text))
        let lineGap = #"{\fs\#(layout.lineSpacing)}\N{\fs\#(layout.fontSize)}\N"#
        let text = lines.joined(separator: lineGap)
        let effects = #"{\fad(\#(fadeInMs),\#(fadeOutMs))\an5\pos(\#(layout.textCenterX),\#(layout.textCenterY))"#
            + softenTag
            + "}"

        return "Dialogue: 0,\(assTime(ms: startMs)),\(assTime(ms: endMs)),Default,,0,0,0,,\(effects)\(text)"
    }

    /// A page boundary goes at every sentence end (.!?); a sentence that would still
    /// wrap past `maxLinesPerPage` is further split at clause boundaries (,;:), packing
    /// consecutive clauses together up to the line cap.
    static func groupIntoPages(_ words: [VideoWordTiming]) -> [[VideoWordTiming]] {
        var pages: [[VideoWordTiming]] = []

        for sentence in split(words, endingWith: ".!?") {
            if lineCount(sentence) <= maxLinesPerPage {
                pages.append(sentence)
                continue
            }

            var pending: [VideoWordTiming] = []
            for clause in split(sentence, endingWith: ",;:") {
                if !pending.isEmpty, lineCount(pending + clause) > maxLinesPerPage {
                    pages.append(pending)
                    pending = []
                }
                pending += clause
            }
            if !pending.isEmpty {
                pages.append(pending)
            }
        }

        return pages
    }

    /// Greedy word-wrap: packs words onto a line until the next one would exceed
    /// `maxCharsPerLine`, matching how the card's fixed-width safe area wraps.
    static func wrapIntoLines(_ words: [String]) -> [String] {
        var lines: [String] = []
        var currentLine: [String] = []
        var currentLength = 0

        for word in words {
            let addedLength = word.count + (currentLine.isEmpty ? 0 : 1)
            if !currentLine.isEmpty, currentLength + addedLength > maxCharsPerLine {
                lines.append(currentLine.joined(separator: " "))
                currentLine = [word]
                currentLength = word.count
            } else {
                currentLine.append(word)
                currentLength += addedLength
            }
        }

        if !currentLine.isEmpty {
            lines.append(currentLine.joined(separator: " "))
        }

        return lines
    }

    private static func lineCount(_ words: [VideoWordTiming]) -> Int {
        wrapIntoLines(words.map(\.text)).count
    }

    private static func split(_ words: [VideoWordTiming], endingWith punctuation: String) -> [[VideoWordTiming]] {
        var groups: [[VideoWordTiming]] = []
        var current: [VideoWordTiming] = []

        for word in words {
            current.append(word)
            if let last = word.text.last, punctuation.contains(last) {
                groups.append(current)
                current = []
            }
        }

        if !current.isEmpty {
            groups.append(current)
        }

        return groups
    }

    private static func assTime(ms: Int) -> String {
        String(
            format: "%d:%02d:%02d.%02d",
            ms / 3_600_000,
            ms % 3_600_000 / 60000,
            ms % 60000 / 1000,
            ms % 1000 / 10
        )
    }
}
