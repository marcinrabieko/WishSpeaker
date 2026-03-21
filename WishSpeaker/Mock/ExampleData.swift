import Foundation

struct ExampleData {
    static let exampleWishes: [Wish] = [
        Wish(
            recipientName: "Gregory",
            occasion: "40th Birthday",
            age: "40",
            tone: "Funny",
            fromPerson: "Marcin",
            relation: "Brother-in-law",
            note: "Works as a paving contractor, owns a company and dreams about a quad.",
            voiceGender: .male,
            generatedText: "Gregory, on your 40th birthday I wish you that everything in life aligns as perfectly as the paving stones you lay every day. May your business grow, your projects succeed and your dream of owning a quad finally become reality. All the best from Marcin.",
            selectedPackage: PremiumPackage(
                name: "Premium",
                description: "High quality audio",
                price: 9.99,
                recommended: true
            )
        ),
        Wish(
            recipientName: "Alicia",
            occasion: "35th Birthday",
            age: "35",
            tone: "Elegant",
            fromPerson: "Ewelina",
            relation: "Boss",
            note: "Kind, supportive, very professional and cultured.",
            voiceGender: .female,
            generatedText: "Alicia, on your 35th birthday I wish you continued success, inspiration and fulfillment both professionally and personally. Thank you for your kindness, professionalism and the positive atmosphere you create every day. With appreciation, Ewelina.",
            selectedPackage: PremiumPackage(
                name: "Premium Plus",
                description: "Ultra quality audio",
                price: 14.99,
                recommended: false
            )
        )
    ]
}
