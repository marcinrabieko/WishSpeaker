import Dependencies
import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

/// The "Hear an example" destination — a miniature Library showing exactly the two
/// curated demo Wishes (ExperienceDemoData), using the same WishLibraryCard/
/// ExampleWishDetailView the real Library uses, so this reads as a natural part of
/// the app rather than a separate marketing page. These demos never get saved to the
/// user's Library — they're static, bundled resources, not WishLibraryManager state.
public struct ExampleWishesView: View {
    @State private var presentedWish: Wish?
    @Environment(\.createFlowPath) private var createFlowPath

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.xs) {
                Text(L10n.exampleWishesSubtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.wsSecondaryText)
                    .padding(.top, WSSpacing.xxs)
                    // Matches WishLibraryCard's own internal spacing between its title
                    // and media (WSSpacing.sm) — the outer VStack spacing above only
                    // covers card-to-card (matches LibraryView's row insets), so this
                    // first gap needs its own top padding to read as equal.
                    .padding(.bottom, WSSpacing.sm - WSSpacing.xs)

                ForEach(ExperienceDemoData.wishes) { wish in
                    WishLibraryCard(wish: wish, showDate: false, onTap: { presentedWish = wish })
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            ctaButton
                .padding(.horizontal, WSSpacing.horizontalPadding)
                .padding(.vertical, WSSpacing.sm)
                .background(Color.wsBackground)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.exampleWishesTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .navigationDestination(item: $presentedWish) { wish in
            ExampleWishDetailView(wish: wish)
        }
    }

    private var ctaButton: some View {
        PrimaryButton(title: L10n.experienceCtaButton) {
            creationManager.startNewWish()
            createFlowPath.wrappedValue.append(CreateFlowRoute.occasionSelection)
        }
    }
}
