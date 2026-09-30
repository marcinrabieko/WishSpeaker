import DesignSystem
import Domain
import ExampleWishesFeature
import LibraryFeature
import Localizations
import OccasionSelectionFeature
import Resources
import SwiftUI

public struct StartView: View {
    @State private var viewModel: StartViewModel

    public init(viewModel: StartViewModel = StartViewModel()) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer(minLength: 0)

                VStack(spacing: WSSpacing.sm) {
                    Resource.iconUniversalTransparent.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)

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
                        viewModel.didTapCreateWish()
                    }

                    Button {
                        viewModel.didTapHearExample()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 15, weight: .medium))
                            Text(L10n.startHearExampleButton)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.wsSecondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: WSSize.minTapTarget)
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.didTapLibrary()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.text.square")
                                .font(.system(size: 14, weight: .semibold))
                            Text(L10n.startLibraryButton)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.wsPrimary)
                        .padding(.horizontal, WSSpacing.sm)
                        .padding(.vertical, WSSpacing.xs)
                        .background(Color.wsPrimary.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, WSSpacing.xs)
                }
                .padding(.horizontal, WSSpacing.horizontalPadding)

                Spacer(minLength: proxy.size.height * 0.12)
            }
        }
        .background(Color.wsBackground)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $viewModel.navigateToCreator) {
            OccasionSelectionView()
        }
        .navigationDestination(isPresented: $viewModel.navigateToExamples) {
            ExampleWishesView()
        }
        .navigationDestination(isPresented: $viewModel.navigateToLibrary) {
            LibraryView()
        }
    }
}
