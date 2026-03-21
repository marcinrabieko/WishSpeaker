import SwiftUI

struct MyWishesView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.generatedWishes.isEmpty {
                VStack {
                    Text("No wishes yet")
                        .foregroundColor(.secondary)
                    Text("Create your first wish to see it here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                List(appState.generatedWishes) { wish in
                    NavigationLink(destination: SavedWishDetailView(wish: wish)) {
                        WishListItem(wish: wish)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Wishes")
    }
}

struct WishListItem: View {
    let wish: Wish

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(wish.recipientName)
                    .font(.headline)
                Spacer()
                Text(wish.occasion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text(wish.tone)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)

                Text(wish.voiceGender.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }

            Text(wish.generatedText.prefix(80) + (wish.generatedText.count > 80 ? "..." : ""))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let appState = AppState()
    appState.generatedWishes = [
        Wish(
            recipientName: "Grzegorz",
            occasion: "Birthday",
            age: "40",
            tone: "Funny",
            fromPerson: "Marcin",
            relation: "Brother-in-law",
            note: "Runs a paving company",
            voiceGender: .male,
            generatedText: "Dear Grzegorz, on your 40th birthday I wish you all the best!",
            selectedPackage: nil
        ),
        Wish(
            recipientName: "Alicja",
            occasion: "Birthday",
            age: "35",
            tone: "Elegant",
            fromPerson: "Ewelina",
            relation: "Boss",
            note: "Kind and professional",
            voiceGender: .female,
            generatedText: "Dear Alicja, wishing you a wonderful birthday!",
            selectedPackage: nil
        )
    ]

    return NavigationStack {
        MyWishesView()
            .environmentObject(appState)
    }
}
