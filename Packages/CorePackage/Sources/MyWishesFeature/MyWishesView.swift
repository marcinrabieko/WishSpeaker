import Dependencies
import DesignSystem
import Domain
import FinalWishFeature
import SharedFeatureComponents
import SwiftUI

@MainActor
@Observable
public final class MyWishesViewModel {
    fileprivate var savedWishes: [Wish] = []

    @ObservationIgnored
    @Dependency(\.wishLibraryManager)
    private var libraryManager: WishLibraryManager

    public init() {}

    func didAppear() {
        savedWishes = libraryManager.savedWishes
    }
}

public struct MyWishesView: View {
    @State private var viewModel = MyWishesViewModel()

    public init() {}

    public var body: some View {
        Group {
            if viewModel.savedWishes.isEmpty {
                EmptyWishesView()
            } else {
                ScrollView {
                    VStack(spacing: WSSpacing.sm) {
                        ForEach(viewModel.savedWishes) { wish in
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
        .onAppear {
            viewModel.didAppear()
        }
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
    NavigationStack {
        MyWishesView()
    }
}
