import SwiftUI
import Domain
import DesignSystem

public struct MyWishesView: View {
    @EnvironmentObject var appState: AppState

    public init() {}

    public var body: some View {
        Group {
            if appState.generatedWishes.isEmpty {
                EmptyWishesView()
            } else {
                ScrollView {
                    VStack(spacing: WSSpacing.sm) {
                        ForEach(appState.generatedWishes) { wish in
                            NavigationLink(destination: SavedWishDetailView(wish: wish)) {
                                WishListCard(wish: wish)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, WSSpacing.horizontalPadding)
                    .padding(.vertical, WSSpacing.sm)
                }
            }
        }
        .background(Color.wsBackground)
        .navigationTitle("My Wishes")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct EmptyWishesView: View {
    var body: some View {
        VStack(spacing: WSSpacing.sm) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 60))
                .foregroundColor(.wsSecondaryText.opacity(0.5))

            Text("No wishes yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.wsPrimaryText)

            Text("Create your first wish to see it here")
                .font(.system(size: 15))
                .foregroundColor(.wsSecondaryText)
        }
    }
}

#Preview {
    let appState = AppState()
    appState.generatedWishes = [
        Wish(
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
        ),
        Wish(
            recipientName: "Alicja",
            occasion: "35th Birthday",
            age: "35",
            tone: "Elegant",
            fromPerson: "Ewelina",
            relation: "Boss",
            note: "Kind and professional",
            voiceGender: .female,
            generatedText: "Alicja, on your 35th birthday I wish you continued success, inspiration and fulfillment both professionally and personally.",
            selectedPackage: nil
        )
    ]

    return NavigationStack {
        MyWishesView()
            .environmentObject(appState)
    }
}
