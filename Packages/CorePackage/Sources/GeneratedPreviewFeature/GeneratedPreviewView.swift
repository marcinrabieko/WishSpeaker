import DesignSystem
import Domain
import Localizations
import PackageSelectionFeature
import SwiftUI

public struct GeneratedPreviewView: View {
    @State private var viewModel = GeneratedPreviewViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: WSSpacing.md) {
                    Text(L10n.generatedPreviewHeading)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.wsPrimaryText)
                        .padding(.top, WSSpacing.sm)

                    Text(viewModel.generatedText)
                        .font(.system(size: 17))
                        .foregroundColor(.wsPrimaryText)
                        .lineSpacing(6)
                        .padding(WSSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.wsSecondaryBackground)
                        .cornerRadius(WSRadius.card)
                }
                .padding(.horizontal, WSSpacing.horizontalPadding)
            }

            Spacer()

            VStack(spacing: WSSpacing.sm) {
                SecondaryButton(title: L10n.generatedPreviewGenerateAgainButton) {
                    viewModel.didTapGenerateAgain()
                }

                PrimaryButton(title: L10n.generatedPreviewContinueButton) {
                    viewModel.didTapContinue()
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.generatedPreviewTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .onAppear {
            viewModel.didAppear()
        }
        .navigationDestination(isPresented: $viewModel.navigateToPackages) {
            PackageSelectionView()
        }
    }
}
