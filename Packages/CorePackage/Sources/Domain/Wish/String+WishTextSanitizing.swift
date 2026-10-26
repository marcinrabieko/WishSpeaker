import Foundation

extension String {
    /// Cleans up generated wish text before it's shown, narrated or burned into a video;
    /// the client-side twin of the backend's `services/text_cleanup.py:sanitize_wish_text()`.
    ///
    /// 1. Repairs typographic punctuation OpenAI sometimes returns with its high byte
    ///    dropped ("Mother\u{19}s" instead of "Mother’s"); those control characters
    ///    render invisibly in the app and as a missing-glyph box in the video.
    /// 2. Replaces em dashes, en dashes and double hyphens with a comma. The prompts
    ///    forbid them, but the model still slips them in, and ElevenLabs' alignment
    ///    returns "—" as "--", which would otherwise land verbatim in the subtitles.
    ///    Number ranges ("5–10") keep a plain hyphen, and a dash opening a line (a
    ///    "— Mom" sign-off) is dropped rather than turned into ", ".
    var sanitizedWishText: String {
        repairingTruncatedPunctuation
            .replacingOccurrences(of: #"(?<=\d)\s*(?:—|–|--)\s*(?=\d)"#, with: "-", options: .regularExpression)
            .replacingOccurrences(of: #"(?m)^[ \t]*(?:—|–|--)[ \t]*"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s*(?:—|–|--)\s*"#, with: ", ", options: .regularExpression)
            .replacingOccurrences(of: #",\s*(?=[,.!?;:])"#, with: "", options: .regularExpression)
    }

    private var repairingTruncatedPunctuation: String {
        let repairs: [Character: Character] = [
            "\u{13}": "–",
            "\u{14}": "—",
            "\u{18}": "‘",
            "\u{19}": "’",
            "\u{1C}": "“",
            "\u{1D}": "”"
        ]

        return String(
            map { character in
                repairs[character] ?? character
            }
        )
    }
}

extension Array where Element == WordTiming {
    /// Applies `sanitizedWishText` to narration words already timed by ElevenLabs (e.g.
    /// a VoiceAsset recorded before the text was cleaned). A word that was nothing but a
    /// dash is dropped, leaving a comma on the word before it.
    var sanitizedWishText: [WordTiming] {
        var words: [WordTiming] = []

        for word in self {
            let text = word.text.sanitizedWishText.trimmingCharacters(in: .whitespaces)

            guard !text.isEmpty, text != "," else {
                if let previous = words.popLast() {
                    let previousText = previous.text.last.map { ",.!?;:".contains($0) } == true
                        ? previous.text
                        : previous.text + ","
                    words.append(WordTiming(text: previousText, startMs: previous.startMs, endMs: previous.endMs))
                }
                continue
            }

            words.append(WordTiming(text: text, startMs: word.startMs, endMs: word.endMs))
        }

        return words
    }
}
