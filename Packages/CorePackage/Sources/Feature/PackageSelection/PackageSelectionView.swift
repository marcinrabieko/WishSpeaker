import SwiftUI
import Domain
import DesignSystem

public struct PackageSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToFinal = false

    private let packages: [PremiumPackage] = [
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

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: WSSpacing.sm) {
                    ForEach(packages) { package in
                        PackageCard(
                            package: package,
                            isSelected: appState.selectedPackage?.id == package.id,
                            onSelect: {
                                appState.selectedPackage = package
                            }
                        )
                    }
                }
                .padding(.horizontal, WSSpacing.horizontalPadding)
                .padding(.top, WSSpacing.sm)
            }

            Spacer()

            PrimaryButton(title: "Continue", action: {
                navigateToFinal = true
            }, isEnabled: appState.selectedPackage != nil)
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.bottom, WSSpacing.lg)
        }
        .background(Color.wsBackground)
        .navigationTitle("Select a Package")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $navigateToFinal) {
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
            .environmentObject(AppState())
    }
}
