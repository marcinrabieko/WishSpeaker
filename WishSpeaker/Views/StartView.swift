import SwiftUI

struct StartView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToCreator = false
    @State private var navigateToExamples = false
    @State private var navigateToMyWishes = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon with gradient
            ZStack {
                Circle()
                    .fill(WSGradient.accent)
                    .frame(width: 90, height: 90)
                    .shadow(color: Color.wsAccent.opacity(0.3), radius: 20, x: 0, y: 10)

                Image(systemName: "waveform")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.bottom, WSSpacing.md)

            // Title
            Text("WishSpeaker")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.wsPrimaryText)
                .padding(.bottom, WSSpacing.xs)

            // Subtitle
            Text("Create AI voice wishes for any occasion")
                .font(.system(size: 17))
                .foregroundColor(.wsSecondaryText)
                .multilineTextAlignment(.center)

            Spacer()

            // Buttons
            VStack(spacing: WSSpacing.sm) {
                PrimaryButton(title: "Create a Wish") {
                    navigateToCreator = true
                }

                SecondaryButton(title: "Hear Examples") {
                    navigateToExamples = true
                }

                if appState.hasGeneratedWish {
                    SecondaryButton(title: "My Wishes") {
                        navigateToMyWishes = true
                    }
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)

            Spacer()

            // Feature list
            VStack(spacing: WSSpacing.sm) {
                FeatureRow(icon: "sparkles", text: "Personal voice messages")
                FeatureRow(icon: "bolt.fill", text: "Generated in seconds")
                FeatureRow(icon: "gift.fill", text: "Perfect for any occasion")
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.xl)
        }
        .background(Color.wsBackground)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToCreator) {
            CreatorFormView()
        }
        .navigationDestination(isPresented: $navigateToExamples) {
            ExampleWishesView()
        }
        .navigationDestination(isPresented: $navigateToMyWishes) {
            MyWishesView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: WSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(WSGradient.accent)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.wsSecondaryText)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        StartView()
            .environmentObject(AppState())
    }
}
