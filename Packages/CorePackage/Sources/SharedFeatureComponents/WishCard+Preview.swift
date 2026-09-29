import DesignSystem
import Domain
import SwiftUI

#Preview {
    ScrollView {
        VStack(spacing: WSSpacing.md) {
            WishCard(
                wish: Wish(
                    recipientName: "Gregory",
                    occasion: "40th Birthday",
                    age: "40",
                    tone: "Funny",
                    fromPerson: "Marcin",
                    relation: "Brother-in-law",
                    note: "Runs a paving company",
                    voiceGender: .male,
                    generatedText: """
                    Gregory, on your 40th birthday I wish you that everything in life aligns as \
                    perfectly as the paving stones you lay every day. May your business grow, \
                    your projects succeed and your dream of owning a quad finally become \
                    reality. All the best from Marcin.
                    """,
                    selectedPackage: nil
                ),
                showFullDetails: true
            )

            WishListCard(
                wish: Wish(
                    recipientName: "Gregory",
                    occasion: "40th Birthday",
                    age: "40",
                    tone: "Funny",
                    fromPerson: "Marcin",
                    relation: "Brother-in-law",
                    note: "Runs a paving company",
                    voiceGender: .male,
                    generatedText: """
                    Gregory, on your 40th birthday I wish you that everything in life aligns as \
                    perfectly as the paving stones you lay every day.
                    """,
                    selectedPackage: nil
                )
            )
        }
        .padding(.horizontal, WSSpacing.horizontalPadding)
    }
}
