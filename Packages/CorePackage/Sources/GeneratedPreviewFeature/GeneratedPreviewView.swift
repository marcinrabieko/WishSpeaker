import DesignSystem
import Domain
import PackageSelectionFeature
import SwiftUI

public struct GeneratedPreviewView: View {
    @State private var viewModel = GeneratedPreviewViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: WSSpacing.md) {
                    // Title
                    Text("Your Generated Wish")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.wsPrimaryText)
                        .padding(.top, WSSpacing.sm)

                    // Generated text card
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

            // Action buttons
            VStack(spacing: WSSpacing.sm) {
                SecondaryButton(title: "Generate Again") {
                    viewModel.didTapGenerateAgain()
                }

                PrimaryButton(title: "Continue") {
                    viewModel.didTapContinue()
                }
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .background(Color.wsBackground)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.didAppear()
        }
        .navigationDestination(isPresented: $viewModel.navigateToPackages) {
            PackageSelectionView()
        }
    }
}
