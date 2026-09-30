import SwiftUI

#Preview {
    NavigationStack {
        CreateView()
    }
}

#Preview("Voice placeholder") {
    NavigationStack {
        VoiceVideoPlaceholderView(kind: .voice)
    }
}

#Preview("Video Card placeholder") {
    NavigationStack {
        VoiceVideoPlaceholderView(kind: .videoCard)
    }
}
