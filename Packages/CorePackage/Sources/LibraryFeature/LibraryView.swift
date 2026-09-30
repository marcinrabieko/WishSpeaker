import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct LibraryView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var presentedWish: Wish?

    public init() {}

    public var body: some View {
        Group {
            if viewModel.savedWishes.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: WSSpacing.sm) {
                        ForEach(viewModel.savedWishes) { wish in
                            WishLibraryCard(wish: wish) {
                                presentedWish = wish
                            }
                        }
                    }
                    .padding(.horizontal, WSSpacing.horizontalPadding)
                    .padding(.vertical, WSSpacing.sm)
                }
            }
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.libraryTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .onAppear {
            viewModel.didAppear()
        }
        .navigationDestination(item: $presentedWish) { wish in
            WishDetailPlaceholderView(wish: wish)
        }
    }

    private var emptyState: some View {
        VStack(spacing: WSSpacing.sm) {
            Spacer()

            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundColor(.wsSecondaryText.opacity(0.5))

            Text(L10n.libraryEmptyTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.wsPrimaryText)

            Text(L10n.libraryEmptySubtitle)
                .font(.system(size: 15))
                .foregroundColor(.wsSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, WSSpacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
