import DesignSystem
import Domain
import FinalWishFeature
import Localizations
import SharedFeatureComponents
import SwiftUI

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
        .navigationTitle(L10n.myWishesTitle)
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

            Text(L10n.myWishesEmptyTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.wsPrimaryText)

            Text(L10n.myWishesEmptySubtitle)
                .font(.system(size: 15))
                .foregroundColor(.wsSecondaryText)
        }
    }
}
