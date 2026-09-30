import DesignSystem
import Domain
import Localizations
import SwiftUI

public struct WishCard: View {
    let wish: Wish
    var showFullDetails: Bool = false

    @State private var showTranscript: Bool = false

    public init(wish: Wish, showFullDetails: Bool = false) {
        self.wish = wish
        self.showFullDetails = showFullDetails
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            VStack(alignment: .leading, spacing: WSSpacing.xs) {
                Text(L10n.wishCardWishFor(wish.recipient))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.wsPrimaryText)

                HStack(spacing: WSSpacing.xs) {
                    Text(wish.occasionTitle)
                        .font(.system(size: 15))
                        .foregroundColor(.wsSecondaryText)

                    Text("•")
                        .foregroundColor(.wsSecondaryText)

                    Text(wish.variant.displayName)
                        .font(.system(size: 15))
                        .foregroundColor(.wsSecondaryText)
                }
            }

            if showFullDetails {
                AudioPlayerView()
                    .padding(.top, WSSpacing.xs)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTranscript.toggle()
                    }
                } label: {
                    HStack {
                        Text(showTranscript ? L10n.wishCardHideTranscriptButton : L10n.wishCardShowTranscriptButton)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.wsPrimary)

                        Spacer()

                        Image(systemName: showTranscript ? "chevron.up" : "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.wsPrimary)
                    }
                    .padding(.vertical, WSSpacing.xs)
                }

                if showTranscript {
                    Text(wish.text)
                        .font(.system(size: 15))
                        .foregroundColor(.wsPrimaryText)
                        .lineSpacing(4)
                        .padding(.top, WSSpacing.xs)
                }
            } else {
                Text(wish.text.prefix(100) + (wish.text.count > 100 ? "..." : ""))
                    .font(.system(size: 15))
                    .foregroundColor(.wsSecondaryText)
                    .lineSpacing(2)
                    .lineLimit(2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(WSRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}
