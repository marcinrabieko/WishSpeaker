import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct FinalWishView: View {
    @State private var viewModel = FinalWishViewModel()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: WSSpacing.md) {
                if let wish = viewModel.wish {
                    WishCard(wish: wish, showFullDetails: true)

                    if let package = viewModel.selectedPackage {
                        PackageSummaryCard(package: package)
                    }
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.finalWishTitle)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.didAppear()
        }
    }
}

struct PackageSummaryCard: View {
    let package: PremiumPackage

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: WSSpacing.xxs) {
                Text(L10n.finalWishPackageLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.wsSecondaryText)
                    .textCase(.uppercase)

                Text(package.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.wsPrimaryText)
            }

            Spacer()

            Text(String(format: "$%.2f", package.price))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.wsAccent)
        }
        .padding(WSSpacing.md)
        .background(Color.wsSecondaryBackground)
        .cornerRadius(WSRadius.card)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// Variant for viewing existing wishes from library
public struct SavedWishDetailView: View {
    let wish: Wish

    public init(wish: Wish) {
        self.wish = wish
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: WSSpacing.md) {
                WishCard(wish: wish, showFullDetails: true)

                if let package = wish.selectedPackage {
                    PackageSummaryCard(package: package)
                }

                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                    Text(L10n.finalWishCreatedAt(wish.createdAt.formatted(date: .abbreviated, time: .shortened)))
                        .font(.system(size: 14))
                }
                .foregroundColor(.wsSecondaryText)
                .padding(.top, WSSpacing.xs)
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.finalWishTitle)
        .navigationBarTitleDisplayMode(.large)
    }
}
