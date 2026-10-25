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
/// page never fades out and stays on screen until the main clip's last frame. When a
/// greeting is given, it's shown as a headline above the first page's text.
enum SubtitleScript {
    static let maxCharsPerLine = 26
    // The headline's larger font fits fewer characters in the same card width — the
    // longest greetings wrap to at most 2 lines at this limit.
    static let maxGreetingCharsPerLine = 23
    static let maxLinesPerPage = 4
    static let pageCrossfadeMs = 400
    static let pageEndHoldMs = 400
    static let pageStartDelayMs = 100
    static let finalPageExtraHoldMs = 800

    private static let fontName = "Libre Baskerville"
    private static let textColor = "&H00121417"
    private static let softenTag = #"\blur1\bord0.5"#

    static func make(
        words: [VideoWordTiming],
        greeting: String?,
        mainDurationMs: Int,
        layout: VideoLayout
    ) -> String {
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
        let dialogueLines = pages.enumerated().flatMap { index, pageWords in
            dialogues(
                pageWords: pageWords,
                greeting: index == 0 ? greeting : nil,
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

    private static func dialogues(
        pageWords: [VideoWordTiming],
        greeting: String?,
        isFirst: Bool,
        isLast: Bool,
        mainDurationMs: Int,
        layout: VideoLayout
    ) -> [String] {
        // The first page is visible from frame 0 (no fade-in), so the opening frame
        // (what a thumbnail captures) is never a blank card.
        let startMs = isFirst ? 0 : (pageWords.first?.startMs ?? 0) + pageStartDelayMs
        let endMs = isLast ? mainDurationMs : (pageWords.last?.endMs ?? 0) + pageCrossfadeMs + pageEndHoldMs
        let fadeInMs = isFirst ? 0 : pageCrossfadeMs
        let fadeOutMs = isLast ? 0 : pageCrossfadeMs

        let timing = "Dialogue: 0,\(assTime(ms: startMs)),\(assTime(ms: endMs)),Default,,0,0,0,,"
        let fade = #"\fad(\#(fadeInMs),\#(fadeOutMs))"#

        let lines = wrapIntoLines(pageWords.map(\.text))
        let text = joinWithLineGap(lines, fontSize: layout.fontSize, layout: layout)
        let textCenterY = greeting == nil ? layout.textCenterY : layout.titlePageTextCenterY
        let effects = "{" + fade + #"\an5\pos(\#(layout.textCenterX),\#(textCenterY))"# + softenTag + "}"

        guard let greeting else {
            return [timing + effects + text]
        }

        // The headline is its own block above the wish text, sharing the first
        // page's timing so both appear and fade together.
        let greetingLines = wrapIntoLines(
            greeting.split(separator: " ").map(String.init),
            maxCharsPerLine: maxGreetingCharsPerLine
        )
        let greetingText = joinWithLineGap(greetingLines, fontSize: layout.greetingFontSize, layout: layout)
        let greetingEffects = "{"
            + fade
            + #"\an5\pos(\#(layout.textCenterX),\#(layout.greetingCenterY))\fs\#(layout.greetingFontSize)\fn\#(fontName)"#
            + softenTag
            + "}"

        return [
            timing + greetingEffects + greetingText,
            timing + effects + text
        ]
    }

    /// ASS has no line-height control for `\N`, so the gap between lines is an extra
    /// blank `\N` rendered at `lineSpacing` size, reset back to `fontSize` right after.
    private static func joinWithLineGap(_ lines: [String], fontSize: Int, layout: VideoLayout) -> String {
        let lineGap = #"{\fs\#(layout.lineSpacing)}\N{\fs\#(fontSize)}\N"#
        return lines.joined(separator: lineGap)
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
    static func wrapIntoLines(_ words: [String], maxCharsPerLine: Int = maxCharsPerLine) -> [String] {
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
