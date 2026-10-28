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

                    secondaryButton(
                        title: L10n.startHearExampleButton,
                        systemImage: "play.fill",
                        action: {
                            viewModel.didTapHearExample()
                        }
                    )

                    // Hidden until there's something to show — a first-time user would
                    // otherwise land on an empty Library.
                    if viewModel.hasSavedWishes {
                        secondaryButton(
                            title: L10n.startLibraryButton,
                            systemImage: "heart",
                            action: {
                                viewModel.didTapLibrary()
                            }
                        )
                    }
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

    private func secondaryButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6.0) {
                Image(systemName: systemImage)
                    .font(.system(size: 15.0, weight: .medium))

                Text(title)
                    .font(.system(size: 16.0, weight: .medium))
            }
            .foregroundColor(.wsSecondaryText)
            .frame(maxWidth: .infinity)
            .frame(height: WSSize.minTapTarget)
        }
        .buttonStyle(.plain)
    }
}
