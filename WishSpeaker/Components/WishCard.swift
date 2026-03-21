import SwiftUI

struct WishCard: View {
    let wish: Wish
    var showFullDetails: Bool = false

    @State private var showTranscript: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header info
            VStack(alignment: .leading, spacing: 8) {
                Text("To: \(wish.recipientName)")
                    .font(.headline)

                HStack {
                    Label(wish.occasion, systemImage: "gift")
                    Spacer()
                    Label(wish.tone, systemImage: "sparkles")
                }
                .font(.subheadline)

                HStack {
                    Label(wish.voiceGender.rawValue + " Voice", systemImage: "waveform")
                    Spacer()
                    if !wish.fromPerson.isEmpty {
                        Text("From: \(wish.fromPerson)")
                            .font(.subheadline)
                    }
                }
            }

            // Text preview (when not showing full details)
            if !showFullDetails {
                Text(wish.generatedText.prefix(100) + (wish.generatedText.count > 100 ? "..." : ""))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            // Audio player (when showing full details)
            if showFullDetails {
                AudioPlayerView()

                // Transcript toggle
                DisclosureGroup("Show Transcript", isExpanded: $showTranscript) {
                    Text(wish.generatedText)
                        .font(.body)
                        .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        WishCard(
            wish: Wish(
                recipientName: "Grzegorz",
                occasion: "Birthday",
                age: "40",
                tone: "Funny",
                fromPerson: "Marcin",
                relation: "Brother-in-law",
                note: "Runs a paving company",
                voiceGender: .male,
                generatedText: "Dear Grzegorz, on your 40th birthday I wish you all the best. May your paving business continue to thrive!",
                selectedPackage: nil
            ),
            showFullDetails: false
        )

        WishCard(
            wish: Wish(
                recipientName: "Grzegorz",
                occasion: "Birthday",
                age: "40",
                tone: "Funny",
                fromPerson: "Marcin",
                relation: "Brother-in-law",
                note: "Runs a paving company",
                voiceGender: .male,
                generatedText: "Dear Grzegorz, on your 40th birthday I wish you all the best. May your paving business continue to thrive!",
                selectedPackage: nil
            ),
            showFullDetails: true
        )
    }
    .padding()
}
