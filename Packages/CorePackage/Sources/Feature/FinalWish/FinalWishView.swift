import SwiftUI
import Domain
import DesignSystem

public struct FinalWishView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasBeenSaved = false

    var wish: Wish {
        Wish(
            form: appState.currentForm,
            generatedText: appState.generatedText,
            selectedPackage: appState.selectedPackage
        )
    }

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: WSSpacing.md) {
                // WishCard with full details
                WishCard(wish: wish, showFullDetails: true)

                // Package summary
                if let package = appState.selectedPackage {
                    PackageSummaryCard(package: package)
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle("Your Wish")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if !hasBeenSaved {
                appState.saveWish()
                hasBeenSaved = true
            }
        }
    }
}

struct PackageSummaryCard: View {
    let package: PremiumPackage

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: WSSpacing.xxs) {
                Text("Package")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.wsSecondaryText)
                    .textCase(.uppercase)

                Text(package.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.wsPrimaryText)
            }

            Spacer()

            Text(String(format: "$%.2f", package.price))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.wsAccent)
        }
        .padding(WSSpacing.md)
        .background(Color.wsSecondaryBackground)
        .cornerRadius(WSRadius.card)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// Variant for viewing existing wishes from library
struct SavedWishDetailView: View {
    let wish: Wish

    init(wish: Wish) {
        self.wish = wish
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WSSpacing.md) {
                // WishCard with full details
                WishCard(wish: wish, showFullDetails: true)

                // Package info
                if let package = wish.selectedPackage {
                    PackageSummaryCard(package: package)
                }

                // Creation date
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                    Text("Created \(wish.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 14))
                }
                .foregroundColor(.wsSecondaryText)
                .padding(.top, WSSpacing.xs)
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle("Your Wish")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    let appState = AppState()
    appState.currentForm = WishForm(
        recipientName: "Gregory",
        occasion: "40th Birthday",
        age: "40",
        tone: "Funny",
        fromPerson: "Marcin",
        relation: "Brother-in-law",
        note: "Runs a paving company",
        voiceGender: .male
    )
    appState.generatedText = "Gregory, on your 40th birthday I wish you that everything in life aligns as perfectly as the paving stones you lay every day. May your business grow, your projects succeed and your dream of owning a quad finally become reality. All the best from Marcin."
    appState.selectedPackage = PremiumPackage(name: "Premium", description: "Studio voice", price: 9.99, recommended: true)

    return NavigationStack {
        FinalWishView()
            .environmentObject(appState)
    }
}
