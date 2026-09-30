import Foundation

public enum ExampleData {
    public static let exampleWishes: [Wish] = [
        Wish(
            occasionKind: .birthday,
            occasionTitle: "40th Birthday",
            recipient: "Gregory",
            context: "Works as a paving contractor, owns a company and dreams about a quad.",
            variant: .warm,
            text: """
            Gregory, on your 40th birthday I wish you that everything in life aligns as \
            perfectly as the paving stones you lay every day. May your business grow, your \
            projects succeed and your dream of owning a quad finally become reality. All the \
            best from Marcin.
            """,
            selectedPackage: PremiumPackage(
                name: "Premium",
                description: "High quality audio",
                price: 9.99,
                recommended: true
            )
        ),
        Wish(
            occasionKind: .birthday,
            occasionTitle: "35th Birthday",
            recipient: "Alicia",
            context: "Kind, supportive, very professional and cultured.",
            variant: .natural,
            text: """
            Alicia, on your 35th birthday I wish you continued success, inspiration and \
            fulfillment both professionally and personally. Thank you for your kindness, \
            professionalism and the positive atmosphere you create every day. With \
            appreciation, Ewelina.
            """,
            selectedPackage: PremiumPackage(
                name: "Premium Plus",
                description: "Ultra quality audio",
                price: 14.99,
                recommended: false
            )
        )
    ]
}
