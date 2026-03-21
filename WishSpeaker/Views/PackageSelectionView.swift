import SwiftUI

struct PackageSelectionView: View {
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

    var body: some View {
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
                        Text("Recommended")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, WSSpacing.xs)
                            .padding(.vertical, WSSpacing.xxs)
                            .background(Color.wsAccent)
                            .cornerRadius(6)
                    }
                }

                Text(String(format: "$%.2f", package.price))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.wsPrimaryText)
            }
            .padding(WSSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.wsSecondaryBackground)
            .cornerRadius(WSRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: WSRadius.card)
                    .stroke(
                        isSelected ? Color.wsAccent : (package.recommended ? Color.wsAccent.opacity(0.3) : Color.clear),
                        lineWidth: isSelected ? 2.5 : 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
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
