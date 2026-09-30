import DesignSystem
import SwiftUI

/// A tappable row advertising a future creation action (e.g. "Create Voice"), styled
/// as a calm Paper surface rather than a solid button — reused wherever WishSpeaker
/// needs to present a premium creation entry point without it reading as disabled.
public struct CreationActionRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void

    public init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: WSSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.wsPrimary.opacity(0.08))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.wsPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.wsPrimaryText)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.wsSecondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.wsSecondaryText.opacity(0.6))
            }
            .padding(WSSpacing.sm)
            .background(Color.wsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous)
                    .stroke(Color.wsSoftBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: WSRadius.card, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
