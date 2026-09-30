import DesignSystem
import Domain
import Localizations
import SwiftUI

public struct ExampleWishesView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: WSSpacing.md) {
                Text(L10n.exampleWishesSubtitle)
                    .font(.system(size: 17))
                    .foregroundColor(.wsSecondaryText)
                    .padding(.top, WSSpacing.xs)

                ForEach(ExampleData.exampleWishes) { wish in
                    ExampleWishCard(wish: wish)
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.exampleWishesTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
    }
}

struct ExampleWishCard: View {
    let wish: Wish
    @State private var showTranscript = false

    var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            VStack(alignment: .leading, spacing: WSSpacing.xs) {
                Text(L10n.exampleWishesWishFor(wish.recipient))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.wsPrimaryText)

                HStack(spacing: WSSpacing.xs) {
                    Text(wish.occasionTitle)
                    Text("•")
                    Text(wish.variant.displayName)
                }
                .font(.system(size: 15))
                .foregroundColor(.wsSecondaryText)
            }

            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
                .padding(.vertical, WSSpacing.xs)

            HStack(spacing: WSSpacing.xs) {
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                Text(L10n.exampleWishesVoiceSuffix)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color.wsPrimary)

            AudioPlayerView()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTranscript.toggle()
                }
            } label: {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 13))
                        Text(showTranscript ? L10n.exampleWishesHideTranscriptButton : L10n.exampleWishesShowTranscriptButton)
                            .font(.system(size: 15, weight: .medium))
                    }
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
            }
        }
        .padding(WSSpacing.md)
        .background(Color(.systemGray6))
        .cornerRadius(WSRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.card)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}
