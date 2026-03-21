import SwiftUI

struct WishCard: View {
    let wish: Wish
    var showFullDetails: Bool = false
    var isCompact: Bool = false

    @State private var showTranscript: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            // Header
            VStack(alignment: .leading, spacing: WSSpacing.xs) {
                Text("Wish for \(wish.recipientName)")
                    .font(.system(size: isCompact ? 17 : 20, weight: .semibold))
                    .foregroundColor(.wsPrimaryText)

                HStack(spacing: WSSpacing.xs) {
                    Text(wish.occasion)
                        .font(.system(size: 15))
                        .foregroundColor(.wsSecondaryText)

                    Text("•")
                        .foregroundColor(.wsSecondaryText)

                    Text(wish.tone)
                        .font(.system(size: 15))
                        .foregroundColor(.wsSecondaryText)
                }
            }

            if showFullDetails {
                // Audio player
                AudioPlayerView()
                    .padding(.top, WSSpacing.xs)

                // Transcript toggle
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTranscript.toggle()
                    }
                }) {
                    HStack {
                        Text(showTranscript ? "Hide Transcript" : "Show Transcript")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.wsAccent)

                        Spacer()

                        Image(systemName: showTranscript ? "chevron.up" : "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.wsAccent)
                    }
                    .padding(.vertical, WSSpacing.xs)
                }

                if showTranscript {
                    Text(wish.generatedText)
                        .font(.system(size: 15))
                        .foregroundColor(.wsPrimaryText)
                        .lineSpacing(4)
                        .padding(.top, WSSpacing.xs)
                }
            } else {
                // Preview text for list view
                Text(wish.generatedText.prefix(100) + (wish.generatedText.count > 100 ? "..." : ""))
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

// Simplified card for list items
struct WishListCard: View {
    let wish: Wish

    var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: WSSpacing.xxs) {
                    Text(wish.recipientName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.wsPrimaryText)

                    HStack(spacing: WSSpacing.xs) {
                        Text(wish.occasion)
                        Text("•")
                        Text(wish.tone)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.wsSecondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.wsSecondaryText.opacity(0.5))
            }

            HStack(spacing: WSSpacing.xs) {
                Image(systemName: "waveform")
                    .font(.system(size: 12))
                Text(wish.voiceGender.rawValue)
                    .font(.system(size: 13))
            }
            .foregroundColor(.wsAccent)

            Text(wish.generatedText.prefix(80) + (wish.generatedText.count > 80 ? "..." : ""))
                .font(.system(size: 14))
                .foregroundColor(.wsSecondaryText)
                .lineLimit(2)
        }
        .padding(WSSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(WSRadius.button)
        .overlay(
            RoundedRectangle(cornerRadius: WSRadius.button)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

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
                    generatedText: "Gregory, on your 40th birthday I wish you that everything in life aligns as perfectly as the paving stones you lay every day. May your business grow, your projects succeed and your dream of owning a quad finally become reality. All the best from Marcin.",
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
                    generatedText: "Gregory, on your 40th birthday I wish you that everything in life aligns as perfectly as the paving stones you lay every day.",
                    selectedPackage: nil
                )
            )
        }
        .padding(.horizontal, WSSpacing.horizontalPadding)
    }
}
