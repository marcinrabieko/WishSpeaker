import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

#Preview("Library — all 3 states") {
    NavigationStack {
        ScrollView {
            VStack(spacing: WSSpacing.sm) {
                ForEach(LibraryPreviewData.all) { wish in
                    WishLibraryCard(wish: wish) {}
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.sm)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.libraryTitle)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Library — empty") {
    NavigationStack {
        LibraryView()
    }
}
