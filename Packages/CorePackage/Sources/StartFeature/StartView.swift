import DesignSystem
import Domain
import ExampleWishesFeature
import MyWishesFeature
import OccasionSelectionFeature
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
                    // Hero image (180pt) with tight spacing to title
                    Image(
                        ImageResource(name: "icon_universal_transparent", bundle: .main)
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)

                    Group {
                        Text("WishSpeaker")
                            .font(WSFont.brandTitle(size: 34))
                            .foregroundColor(.wsPrimaryText)
                    }

                    // Subtitle
                    Text("Make every wish sound personal.")
                        .font(.system(size: 17))
                        .foregroundColor(.wsSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)

                    // Deliberate gap between subtitle and primary CTA (~32pt)
                    Spacer().frame(height: 32)

                    // Primary CTA
                    PrimaryButton(title: "Create a Wish") {
                        viewModel.didTapCreateWish()
                    }

                    // Secondary action as text button (medium 16pt, Warm Gray)
                    Button {
                        viewModel.didTapHearExample()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 15, weight: .medium))
                            Text("Hear an example")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.wsSecondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: WSSize.minTapTarget)
                    }
                    .buttonStyle(.plain)
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
        .navigationDestination(isPresented: $viewModel.navigateToMyWishes) {
            MyWishesView()
        }
    }
}
