import SwiftUI

struct ExampleWishesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("See how WishSpeaker works with these example wishes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ForEach(ExampleData.exampleWishes) { wish in
                    ExampleWishCard(wish: wish)
                }
            }
            .padding()
        }
        .navigationTitle("Example Wishes")
    }
}

struct ExampleWishCard: View {
    let wish: Wish
    @State private var showTranscript = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("To: \(wish.recipientName)")
                    .font(.headline)

                HStack {
                    Text("Occasion: \(wish.occasion)")
                    Spacer()
                }
                .font(.subheadline)

                HStack {
                    Text("Tone: \(wish.tone)")
                    Spacer()
                    Text("From: \(wish.fromPerson)")
                }
                .font(.subheadline)

                Text("Relation: \(wish.relation)")
                    .font(.subheadline)

                if !wish.note.isEmpty {
                    Text("Note: \(wish.note)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Voice info
            HStack {
                Image(systemName: "waveform")
                Text("\(wish.voiceGender.rawValue) Voice")
            }
            .font(.subheadline)

            // Audio player
            AudioPlayerView()

            // Transcript toggle
            DisclosureGroup("Show Transcript", isExpanded: $showTranscript) {
                Text(wish.generatedText)
                    .font(.body)
                    .padding(.top, 8)
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
    NavigationStack {
        ExampleWishesView()
    }
}
