import Foundation

public struct WishForm: Sendable {
    public var recipientName: String = ""
    public var occasion: String = ""
    public var relation: String = ""
    public var note: String = ""
    public var voiceGender: VoiceGender = .male

    public init(
        recipientName: String = "",
        occasion: String = "",
        relation: String = "",
        note: String = "",
        voiceGender: VoiceGender = .male
    ) {
        self.recipientName = recipientName
        self.occasion = occasion
        self.relation = relation
        self.note = note
        self.voiceGender = voiceGender
    }
}

public enum VoiceGender: String, CaseIterable, Sendable {
    case male = "Male"
    case female = "Female"
}
