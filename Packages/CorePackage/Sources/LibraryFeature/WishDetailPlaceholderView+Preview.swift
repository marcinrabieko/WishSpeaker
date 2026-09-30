import Domain
import SwiftUI

#Preview("Text only") {
    NavigationStack {
        WishDetailPlaceholderView(wish: LibraryPreviewData.textOnlyBirthdayWish)
    }
}

#Preview("With voice") {
    NavigationStack {
        WishDetailPlaceholderView(wish: LibraryPreviewData.voiceBirthdayWish)
    }
}

#Preview("With video") {
    NavigationStack {
        WishDetailPlaceholderView(wish: LibraryPreviewData.videoWeddingWish)
    }
}
