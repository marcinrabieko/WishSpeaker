import DesignSystem
import Localizations
import SwiftUI

public enum CreationKind: Identifiable {
    case voice
    case videoCard

    public var id: Self {
        self
    }

    var title: String {
        switch self {
        case .voice:
            L10n.createViewVoiceTitle

        case .videoCard:
            L10n.createViewVideoCardTitle
        }
    }

    var iconName: String {
        switch self {
        case .voice:
            "waveform"

        case .videoCard:
            "video.fill"
        }
    }
}

/// Clean navigation boundary for the future Voice / Video Card creation flows —
/// no selection, TTS, templates, or paywall here (see CLAUDE.md task scope).
public struct VoiceVideoPlaceholderView: View {
    let kind: CreationKind

    public init(kind: CreationKind) {
        self.kind = kind
    }

    public var body: some View {
        VStack(spacing: WSSpacing.sm) {
            Spacer()

            Image(systemName: kind.iconName)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(Color.wsPrimary)

            Text(kind.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.wsPrimaryText)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.wsBackground)
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
    }
}
