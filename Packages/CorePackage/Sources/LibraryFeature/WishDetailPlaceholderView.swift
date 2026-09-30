import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

/// Minimal navigation boundary for a saved Wish. The full detail screen — Copy, Edit,
/// Create Voice/Video, Play, Share, Download, Delete — is a future implementation step.
struct WishDetailPlaceholderView: View {
    let wish: Wish

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WSSpacing.md) {
                WishLibraryCard(wish: wish)

                Text(wish.text)
                    .font(.system(size: 16))
                    .foregroundColor(.wsPrimaryText)
                    .lineSpacing(5)
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.libraryCardTitle(wish.occasionTitle, wish.recipient))
        .navigationBarTitleDisplayMode(.inline)
        .wsBackButton()
    }
}
