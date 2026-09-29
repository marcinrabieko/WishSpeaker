import Dependencies
import DesignSystem
import Domain
import FinalWishFeature
import SwiftUI

@MainActor
@Observable
public final class PackageSelectionViewModel {
    let packages: [PremiumPackage] = [
        PremiumPackage(
            name: "Basic",
            description: "Standard AI voice",
            price: 4.99,
            recommended: false
        ),
        PremiumPackage(
            name: "Premium",
            description: "Studio voice",
            price: 9.99,
            recommended: true
        ),
        PremiumPackage(
            name: "Premium Plus",
            description: "Studio voice + music",
            price: 14.99,
            recommended: false
        )
    ]

    fileprivate var navigateToFinal = false
    fileprivate var selectedPackage: PremiumPackage?

    @ObservationIgnored
    @Dependency(\.wishCreationManager)
    private var creationManager: WishCreationManager

    public init() {}

    func didAppear() {
        selectedPackage = creationManager.selectedPackage
    }

    func didSelectPackage(_ package: PremiumPackage) {
        selectedPackage = package
        creationManager.selectedPackage = package
    }

    func didTapContinue() {
        navigateToFinal = true
    }
}

public struct PackageSelectionView: View {
    @State private var viewModel = PackageSelectionViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: WSSpacing.sm) {
                    ForEach(viewModel.packages) { package in
                        PackageCard(
                            package: package,
                            isSelected: viewModel.selectedPackage?.id == package.id,
                            onSelect: {
                                viewModel.didSelectPackage(package)
                            }
                        )
                    }
                }
                .padding(.horizontal, WSSpacing.horizontalPadding)
                .padding(.top, WSSpacing.sm)
            }

            Spacer()

            PrimaryButton(
                title: "Continue",
                action: {
                    viewModel.didTapContinue()
                },
                isEnabled: viewModel.selectedPackage != nil
            )
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .background(Color.wsBackground)
        .navigationTitle("Select a Package")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.didAppear()
        }
        .navigationDestination(isPresented: $viewModel.navigateToFinal) {
            FinalWishView()
        }
    }
}

struct PackageCard: View {
    let package: PremiumPackage
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: WSSpacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: WSSpacing.xxs) {
                        Text(package.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.wsPrimaryText)

                        Text(package.description)
                            .font(.system(size: 15))
                            .foregroundColor(.wsSecondaryText)
                    }

                    Spacer()

                    if package.recommended {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Recommended")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.wsAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.wsAccent.opacity(0.15))
                        .cornerRadius(10)
                    }
                }

                Text(String(format: "$%.2f", package.price))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.wsPrimaryText)
            }
            .padding(WSSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(WSRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: WSRadius.card)
                    .stroke(
                        isSelected ? Color.wsAccent : (package.recommended ? Color.wsAccent : Color(.systemGray5)),
                        lineWidth: isSelected ? 2 : (package.recommended ? 2 : 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    NavigationStack {
        PackageSelectionView()
    }
}
