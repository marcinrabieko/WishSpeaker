import SwiftUI

struct GeneratedPreviewView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToPackages = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: WSSpacing.md) {
                    // Title
                    Text("Your Generated Wish")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.wsPrimaryText)
                        .padding(.top, WSSpacing.sm)

                    // Generated text card
                    Text(appState.generatedText)
                        .font(.system(size: 17))
                        .foregroundColor(.wsPrimaryText)
                        .lineSpacing(6)
                        .padding(WSSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.wsSecondaryBackground)
                        .cornerRadius(WSRadius.card)
                }
                .padding(.horizontal, WSSpacing.horizontalPadding)
            }

            Spacer()

            // Action buttons
            VStack(spacing: WSSpacing.sm) {
                SecondaryButton(title: "Generate Again") {
                    regenerateWish()
                }

                PrimaryButton(title: "Continue") {
                    navigateToPackages = true
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .background(Color.wsBackground)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $navigateToPackages) {
            PackageSelectionView()
        }
    }

    private func regenerateWish() {
        appState.generatedText = MockWishGenerator.shared.generateMockWish(form: appState.currentForm)
    }
}

#Preview {
    let appState = AppState()
    appState.generatedText = "Dear Gregory, on your 40th birthday I wish you that everything in life aligns as perfectly as the paving stones you lay every day. May your business grow, your projects succeed and your dream of owning a quad finally become reality. All the best from Marcin."

    return NavigationStack {
        GeneratedPreviewView()
            .environmentObject(appState)
    }
}
