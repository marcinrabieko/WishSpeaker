import DesignSystem
import Domain
import SwiftUI

#Preview {
    ScrollView {
        VStack(spacing: WSSpacing.md) {
            WishCard(
                wish: Wish(
                    occasionKind: .birthday,
                    occasionTitle: "40th Birthday",
                    recipient: "Gregory",
                    context: "Runs a paving company",
                    variant: .warm,
                    text: """
                    Gregory, on your 40th birthday I wish you that everything in life aligns as \
                    perfectly as the paving stones you lay every day. May your business grow, \
                    your projects succeed and your dream of owning a quad finally become \
                    reality. All the best from Marcin.
                    """,
                    selectedPackage: nil
                ),
                showFullDetails: true
            )
        }
        .padding(.horizontal, WSSpacing.horizontalPadding)
    }
}
