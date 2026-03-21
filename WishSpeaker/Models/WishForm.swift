import Foundation

struct WishForm {
    var recipientName: String = ""
    var occasion: String = ""
    var age: String = ""
    var tone: String = ""
    var fromPerson: String = ""
    var relation: String = ""
    var note: String = ""
    var voiceGender: VoiceGender = .male
}

enum VoiceGender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
}
