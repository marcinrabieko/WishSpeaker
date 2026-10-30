import DesignSystem
import Domain
import ExampleWishesFeature
import FormFeature
import LibraryFeature
import Localizations
import OccasionSelectionFeature
import Resources
import SwiftUI
import WishesFeature

public struct StartView: View {
    @State private var viewModel: StartViewModel
    @Environment(\.createFlowPath) private var createFlowPath

    public init(viewModel: StartViewModel = StartViewModel()) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer(minLength: 0)

                VStack(spacing: WSSpacing.sm) {
                    heroEnvelope

                    Group {
                        Text(L10n.startTitle)
                            .font(WSFont.brandTitle(size: 34))
                            .foregroundColor(.wsPrimaryText)
                    }

                    Text(L10n.startSubtitle)
                        .font(.system(size: 17))
                        .foregroundColor(.wsSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)

                    // Deliberate gap between subtitle and primary CTA (~32pt)
                    Spacer().frame(height: 32)

                    PrimaryButton(title: L10n.startCreateWishButton) {
                        viewModel.didTapCreateWish(path: createFlowPath)
                    }

                    // Side by side when they fit, stacked otherwise (longer Polish copy) —
                    // both arrangements give every pill the width of the widest one.
                    ViewThatFits(in: .horizontal) {
                        EqualWidthHStack(spacing: WSSpacing.xs) {
                            secondaryPills
                        }

                        VStack(spacing: WSSpacing.xs) {
                            secondaryPills
                        }
                        .fixedSize()
                    }
                    .padding(.top, WSSpacing.sm)
                }
                .padding(.horizontal, WSSpacing.horizontalPadding)

                Spacer(minLength: proxy.size.height * 0.12)
            }
        }
        .background {
            Resource.startBackgroundBokeh.swiftUIImage
                .resizable()
                .scaledToFill()
        }
        .background(Color.wsBackground)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            viewModel.didAppear()

            #if DEBUG
            runScreenshotDemo()
            #endif
        }
        .navigationDestination(isPresented: $viewModel.navigateToExamples) {
            ExampleWishesView()
        }
        .navigationDestination(isPresented: $viewModel.navigateToLibrary) {
            LibraryView()
        }
        .navigationDestination(for: CreateFlowRoute.self) { route in
            switch route {
            case .occasionSelection:
                OccasionSelectionView()

            case .form:
                FormView()

            case .wishes:
                WishesView()

            case .create:
                WishResultView.fromCreationFlow()
            }
        }
    }

    /// Slow, subtle float — deliberately calmer than GeneratingView's wobble of the same
    /// envelope, so the idle Start screen never reads as "something is loading". The glow
    /// stays static, unlike GeneratingView's pulsing one.
    private var heroEnvelope: some View {
        ZStack {
            Circle()
                .fill(Color.wsGlow)
                .frame(width: 170.0, height: 170.0)
                .blur(radius: 40.0)
                .opacity(0.7)

            Resource.iconUniversalTransparent.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 180.0)
                .phaseAnimator([false, true]) { content, isRaised in
                    content
                        .offset(y: isRaised ? -6.0 : 0.0)
                        .rotationEffect(.degrees(isRaised ? 1.5 : -1.5))
                } animation: { _ in
                    .easeInOut(duration: 2.8)
                }
        }
    }

    /// Library pill hidden until there's something to show — a first-time user would
    /// otherwise land on an empty Library.
    @ViewBuilder
    private var secondaryPills: some View {
        secondaryPill(
            title: L10n.startHearExampleButton,
            systemImage: "play.fill",
            action: {
                viewModel.didTapHearExample()
            }
        )

        if viewModel.hasSavedWishes {
            secondaryPill(
                title: L10n.startLibraryButton,
                systemImage: "heart",
                action: {
                    viewModel.didTapLibrary()
                }
            )
        }
    }

    private func secondaryPill(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6.0) {
                Image(systemName: systemImage)
                    .font(.system(size: 14.0, weight: .semibold))

                Text(title)
                    .font(.system(size: 14.0, weight: .semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.wsPrimary)
            .padding(.horizontal, WSSpacing.sm)
            .padding(.vertical, WSSpacing.xs)
            .background(Color.wsPrimary.opacity(0.08))
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#if DEBUG
private extension StartView {
    /// Start is both where the walkthrough begins and where it returns to for the
    /// Library and Examples screenshots, taken after the App Preview part is over.
    func runScreenshotDemo() {
        ScreenshotDemo.run(.start) {
            ScreenshotDemo.mark("preview-start")
            await ScreenshotDemo.pause(1.5)
            await ScreenshotDemo.capture("01-start")

            viewModel.didTapCreateWish(path: createFlowPath)
        }

        ScreenshotDemo.run(.libraryAndExamples) {
            ScreenshotDemo.seedLibrary()
            viewModel.didAppear()
            await ScreenshotDemo.pause(1.0)

            viewModel.didTapLibrary()
            await ScreenshotDemo.pause(1.2)
            await ScreenshotDemo.capture("06-library")

            viewModel.navigateToLibrary = false
            await ScreenshotDemo.pause(1.2)

            viewModel.didTapHearExample()
            await ScreenshotDemo.pause(1.2)
            await ScreenshotDemo.capture("07-examples")

            ScreenshotDemo.mark("finished")
        }
    }
}
#endif

/// An HStack that sizes every subview to the widest one's ideal width — `.fixedSize()` only
/// achieves that for a VStack, an HStack keeps each child at its own ideal width.
private struct EqualWidthHStack: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let itemSize = maxIdealSize(of: subviews)
        let totalSpacing = spacing * CGFloat(max(subviews.count - 1, 0))

        return CGSize(width: itemSize.width * CGFloat(subviews.count) + totalSpacing, height: itemSize.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let itemSize = maxIdealSize(of: subviews)
        var x = bounds.minX

        for subview in subviews {
            subview.place(at: CGPoint(x: x, y: bounds.midY), anchor: .leading, proposal: ProposedViewSize(itemSize))
            x += itemSize.width + spacing
        }
    }

    private func maxIdealSize(of subviews: Subviews) -> CGSize {
        subviews.reduce(.zero) { result, subview in
            let size = subview.sizeThatFits(.unspecified)

            return CGSize(width: max(result.width, size.width), height: max(result.height, size.height))
        }
    }
}
