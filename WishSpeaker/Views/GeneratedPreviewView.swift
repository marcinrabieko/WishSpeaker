import SwiftUI

struct GeneratedPreviewView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToPackages = false

    var body: some View {
        VStack(spacing: 24) {
            // Generated text display
            ScrollView {
                Text(appState.generatedText)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button(action: regenerateWish) {
                    Text("Generate Again")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: {
                    navigateToPackages = true
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .navigationTitle("Preview")
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
    appState.generatedText = "Dear John, on your special Birthday, I wish you all the best. May this day bring you joy and happiness. With warm wishes, Jane (your friend)"

    return NavigationStack {
        GeneratedPreviewView()
            .environmentObject(appState)
    }
}
