import SwiftUI

struct StartView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Title
            Text("WishSpeaker")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            // Navigation buttons
            VStack(spacing: 16) {
                NavigationLink(destination: CreatorFormView()) {
                    Text("Create Wishes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: ExampleWishesView()) {
                    Text("Example Wishes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                // My Wishes button - only visible after generating at least one wish
                if appState.hasGeneratedWish {
                    NavigationLink(destination: MyWishesView()) {
                        Text("My Wishes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        StartView()
            .environmentObject(AppState())
    }
}
