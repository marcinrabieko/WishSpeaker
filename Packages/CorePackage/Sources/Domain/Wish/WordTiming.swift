import Foundation

/// A single word's spoken timing within a generated VoiceAsset's audio — saved
/// alongside the audio file so Video generation can reuse both without re-synthesizing
/// speech (and the word-level alignment that comes with it) through ElevenLabs.
public struct WordTiming: Codable, Hashable, Sendable {
    public let text: String
    public let startMs: Int
    public let endMs: Int

    public init(text: String, startMs: Int, endMs: Int) {
        self.text = text
        self.startMs = startMs
        self.endMs = endMs
    }
}
