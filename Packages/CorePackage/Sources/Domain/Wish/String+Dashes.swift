import Foundation

extension String {
    /// Replaces em dashes, en dashes and double hyphens with a comma — the client-side
    /// twin of the backend's `services/text_cleanup.py:replace_dashes()`. The prompts
    /// forbid them, but the model still slips them in, and ElevenLabs' alignment
    /// returns "—" as "--", which would otherwise land verbatim in the video subtitles.
    ///
    /// Number ranges ("5–10") keep a plain hyphen, and a dash opening a line (a "— Mom"
    /// sign-off) is dropped rather than turned into ", ".
    var replacingDashes: String {
        self
            .replacingOccurrences(of: #"(?<=\d)\s*(?:—|–|--)\s*(?=\d)"#, with: "-", options: .regularExpression)
            .replacingOccurrences(of: #"(?m)^[ \t]*(?:—|–|--)[ \t]*"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s*(?:—|–|--)\s*"#, with: ", ", options: .regularExpression)
            .replacingOccurrences(of: #",\s*(?=[,.!?;:])"#, with: "", options: .regularExpression)
    }
}

extension Array where Element == WordTiming {
    /// Applies `replacingDashes` to narration words already timed by ElevenLabs (e.g. a
    /// VoiceAsset recorded before the text was cleaned). A word that was nothing but a
    /// dash is dropped, leaving a comma on the word before it.
    var replacingDashes: [WordTiming] {
        var words: [WordTiming] = []

        for word in self {
            let text = word.text.replacingDashes.trimmingCharacters(in: .whitespaces)

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
