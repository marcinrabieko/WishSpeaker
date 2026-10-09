import DesignSystem
import SwiftUI

/// One self-contained Liquid Glass capsule (icon + single-line label), shared by every
/// screen that needs a compact secondary action pill (e.g. WishesFeature's Copy/Save/
/// Retry row, LibraryFeature's Copy/Edit row under the wish text). True
/// `glassEffect`/`GlassEffectContainer` on iOS 26+; `.ultraThinMaterial` is the closest
/// native stand-in below that — never a hand-rolled blur/opacity/gradient approximation
/// of glass. `isHighlighted` only tints the icon+label Ribbon Red (e.g. once Saved) —
/// the capsule background itself always stays neutral, keeping the pill visually
/// secondary to whatever primary CTA sits near it.
public struct GlassPillButton: View {
    let title: String
    let icon: String
    let isHighlighted: Bool
    let action: () -> Void
    var isDisabled: Bool
    var minHeight: CGFloat

    public init(
        title: String,
        icon: String,
        isHighlighted: Bool = false,
        isDisabled: Bool = false,
        minHeight: CGFloat = WSSize.minTapTarget,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isHighlighted = isHighlighted
        self.isDisabled = isDisabled
        self.minHeight = minHeight
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
        .modifier(GlassCapsuleModifier())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }

    private var label: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(isHighlighted ? Color.wsPrimary : Color.wsPrimaryText)
        .padding(.horizontal, WSSpacing.sm)
        .frame(minHeight: minHeight)
    }
}

/// True `glassEffect`/`GlassEffectContainer` on iOS 26+; `.ultraThinMaterial` is the
/// closest native stand-in below that — never a hand-rolled blur/opacity/gradient
/// approximation of glass.
private struct GlassCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            GlassEffectContainer {
                content
            }
            .glassEffect(.regular, in: Capsule())
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}
