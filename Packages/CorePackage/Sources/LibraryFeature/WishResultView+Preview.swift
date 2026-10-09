import Domain
import SwiftUI

#Preview("Library — Text only") {
    NavigationStack {
        WishResultView(wish: LibraryPreviewData.textOnlyBirthdayWish)
    }
}

#Preview("Library — With voice") {
    NavigationStack {
        WishResultView(wish: LibraryPreviewData.voiceBirthdayWish)
    }
}

#Preview("Library — With video") {
    NavigationStack {
        WishResultView(wish: LibraryPreviewData.videoWeddingWish)
    }
}
