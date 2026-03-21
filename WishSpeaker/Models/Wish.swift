import Foundation

struct Wish: Identifiable {
    let id: UUID
    let recipientName: String
    let occasion: String
    let age: String
    let tone: String
    let fromPerson: String
    let relation: String
    let note: String
    let voiceGender: VoiceGender
    let generatedText: String
    let selectedPackage: PremiumPackage?
    let createdAt: Date
    let audioFile: String
    let duration: TimeInterval

    init(
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

    init(form: WishForm, generatedText: String, selectedPackage: PremiumPackage?) {
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
