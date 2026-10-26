import Resources
import SwiftUI

public extension View {
    /// WishSpeaker's screen background: the cream `wsBackground` with a soft golden bokeh band
    /// pinned to the top edge (behind the navigation bar and large title). The band stays put
    /// while content scrolls over it, and is kept subtler than the Start screen's full artwork.
    func wsDecoratedBackground() -> some View {
        background {
            ZStack(alignment: .top) {
                Color.wsBackground

                Resource.topBackgroundBokeh.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .opacity(0.7)
            }
            .ignoresSafeArea()
        }
    }
}
