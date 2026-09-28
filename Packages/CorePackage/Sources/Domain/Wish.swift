import Foundation

public struct Wish: Identifiable, Sendable {
    public let id: UUID
    public let recipientName: String
    public let occasion: String
    public let age: String
    public let tone: String
    public let fromPerson: String
    public let relation: String
    public let note: String
    public let voiceGender: VoiceGender
    public let generatedText: String
    public let selectedPackage: PremiumPackage?
    public let createdAt: Date
    public let audioFile: String
    public let duration: TimeInterval

    public init(
        id: UUID = UUID(),
        recipientName: String,
        occasion: String,
        age: String,
        tone: String,
        fromPerson: String,
        relation: String,
        note: String,
        voiceGender: VoiceGender,
        generatedText: String,
        selectedPackage: PremiumPackage?,
        createdAt: Date = Date(),
        audioFile: String = "example_audio",
        duration: TimeInterval = 30.0
    ) {
        self.id = id
        self.recipientName = recipientName
        self.occasion = occasion
        self.age = age
        self.tone = tone
        self.fromPerson = fromPerson
        self.relation = relation
        self.note = note
        self.voiceGender = voiceGender
        self.generatedText = generatedText
        self.selectedPackage = selectedPackage
        self.createdAt = createdAt
        self.audioFile = audioFile
        self.duration = duration
    }

    public init(form: WishForm, generatedText: String, selectedPackage: PremiumPackage?) {
        self.id = UUID()
        self.recipientName = form.recipientName
        self.occasion = form.occasion
        self.age = form.age
        self.tone = form.tone
        self.fromPerson = form.fromPerson
        self.relation = form.relation
        self.note = form.note
        self.voiceGender = form.voiceGender
        self.generatedText = generatedText
        self.selectedPackage = selectedPackage
        self.createdAt = Date()
        self.audioFile = "example_audio"
        self.duration = 30.0
    }
}
