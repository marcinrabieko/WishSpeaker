import Resources
import SwiftUI

/// Full-screen "please wait" state shown while a long-running generation request (voice
/// or video) is in flight: a gently floating gift with twinkling sparkles over the
/// decorated background, plus a title and subtitle.
public struct GeneratingView: View {
    let title: String
    let subtitle: String

    @State private var isAnimating = false

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: WSSpacing.md) {
            Spacer()

            giftAnimation

            VStack(spacing: WSSpacing.xs) {
                Text(title)
                    .font(WSFont.brandTitle(size: 26.0))
                    .foregroundColor(.wsPrimaryText)

                Text(subtitle)
                    .font(.system(size: 16.0))
                    .foregroundColor(.wsSecondaryText)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, WSSpacing.xl)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .wsDecoratedBackground()
        .onAppear {
            isAnimating = true
        }
    }

    private var giftAnimation: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "F3D9A4"))
                .frame(width: 160.0, height: 160.0)
                .blur(radius: 40.0)
                .scaleEffect(isAnimating ? 1.15 : 0.85)
                .opacity(isAnimating ? 0.9 : 0.5)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: isAnimating)

            Resource.iconUniversalTransparent.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 160.0)
                .rotationEffect(.degrees(isAnimating ? 4.0 : -4.0))
                .offset(y: isAnimating ? -10.0 : 6.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)

            sparkle(size: 22.0, x: -88.0, y: -62.0, delay: 0.0)
            sparkle(size: 14.0, x: 92.0, y: -40.0, delay: 0.5)
            sparkle(size: 18.0, x: 70.0, y: 58.0, delay: 1.0)
            sparkle(size: 12.0, x: -76.0, y: 48.0, delay: 0.75)
        }
        .frame(width: 240.0, height: 220.0)
    }

    private func sparkle(size: CGFloat, x: CGFloat, y: CGFloat, delay: Double) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(Color(hex: "E3B35C"))
            .scaleEffect(isAnimating ? 1.0 : 0.3)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(x: x, y: y)
            .animation(
                .easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(delay),
                value: isAnimating
            )
    }
}

#Preview {
    GeneratingView(
        title: "Wrapping up your video…",
        subtitle: "This may take a little while. Please keep the app open."
    )
}
