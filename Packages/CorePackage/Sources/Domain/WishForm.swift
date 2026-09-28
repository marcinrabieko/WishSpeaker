import Foundation

public struct WishForm: Sendable {
    public var recipientName: String = ""
    public var occasion: String = ""
    public var age: String = ""
    public var tone: String = ""
    public var fromPerson: String = ""
    public var relation: String = ""
    public var note: String = ""
    public var voiceGender: VoiceGender = .male

    public init(
        recipientName: String = "",
        occasion: String = "",
        age: String = "",
        tone: String = "",
        fromPerson: String = "",
        relation: String = "",
        note: String = "",
        voiceGender: VoiceGender = .male
    ) {
        self.recipientName = recipientName
        self.occasion = occasion
        self.age = age
        self.tone = tone
        self.fromPerson = fromPerson
        self.relation = relation
        self.note = note
        self.voiceGender = voiceGender
    }
}

public enum VoiceGender: String, CaseIterable, Sendable {
    case male = "Male"
    case female = "Female"
}
