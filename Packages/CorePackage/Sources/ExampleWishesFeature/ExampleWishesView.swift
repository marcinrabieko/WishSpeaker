import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct ExampleWishesView: View {
    @State private var presentedWish: Wish?

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: WSSpacing.sm) {
                Text(L10n.exampleWishesSubtitle)
                    .font(.system(size: 17))
                    .foregroundColor(.wsSecondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, WSSpacing.xs)

                ForEach(ExampleData.exampleWishes) { wish in
                    WishLibraryCard(wish: wish, showDate: false, onTap: { presentedWish = wish })
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.exampleWishesTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .navigationDestination(item: $presentedWish) { wish in
            ExampleWishDetailView(wish: wish)
        }
    }
}
