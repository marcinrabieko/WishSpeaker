import SwiftUI

struct FinalWishView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasBeenSaved = false

    var wish: Wish {
        Wish(
            form: appState.currentForm,
            generatedText: appState.generatedText,
            selectedPackage: appState.selectedPackage
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Wish for \(appState.currentForm.recipientName)")
                    .font(.title2)
                    .fontWeight(.bold)

                // Voice info
                HStack {
                    Image(systemName: "waveform")
                    Text("\(appState.currentForm.voiceGender.rawValue) Voice")
                }
                .font(.subheadline)

                // Audio player
                AudioPlayerView()

                // Transcript section
                DisclosureGroup("Show Transcript") {
                    Text(appState.generatedText)
                        .font(.body)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                // Package info
                if let package = appState.selectedPackage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Package: \(package.name)")
                            .font(.subheadline)
                        Text(String(format: "Price: $%.2f", package.price))
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Your Wish")
        .onAppear {
            if !hasBeenSaved {
                appState.saveWish()
                hasBeenSaved = true
            }
        }
    }
}

// Variant for viewing existing wishes from library
struct SavedWishDetailView: View {
    let wish: Wish

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Wish for \(wish.recipientName)")
                    .font(.title2)
                    .fontWeight(.bold)

                // Voice info
                HStack {
                    Image(systemName: "waveform")
                    Text("\(wish.voiceGender.rawValue) Voice")
                }
                .font(.subheadline)

                // Audio player
                AudioPlayerView()

                // Transcript section
                DisclosureGroup("Show Transcript") {
                    Text(wish.generatedText)
                        .font(.body)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                // Package info
                if let package = wish.selectedPackage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Package: \(package.name)")
                            .font(.subheadline)
                        Text(String(format: "Price: $%.2f", package.price))
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }

                // Creation date
                Text("Created: \(wish.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Your Wish")
    }
}

#Preview {
    let appState = AppState()
    appState.currentForm = WishForm(
        recipientName: "Grzegorz",
        occasion: "Birthday",
        age: "40",
        tone: "Funny",
        fromPerson: "Marcin",
        relation: "Brother-in-law",
        note: "Runs a paving company",
        voiceGender: .male
    )
    appState.generatedText = "Dear Grzegorz, on your 40th birthday I wish you all the best!"
    appState.selectedPackage = PremiumPackage(name: "Premium", description: "High quality", price: 9.99, recommended: true)

    return NavigationStack {
        FinalWishView()
            .environmentObject(appState)
    }
}
