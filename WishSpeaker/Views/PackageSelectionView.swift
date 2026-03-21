import SwiftUI

struct PackageSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToFinal = false

    private let packages: [PremiumPackage] = [
        PremiumPackage(
            name: "Basic",
            description: "Standard quality audio with basic voice options",
            price: 4.99,
            recommended: false
        ),
        PremiumPackage(
            name: "Premium",
            description: "High quality audio with premium voice selection",
            price: 9.99,
            recommended: true
        ),
        PremiumPackage(
            name: "Premium Plus",
            description: "Ultra quality audio with all voice options and priority processing",
            price: 14.99,
            recommended: false
        )
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Select a Package")
                .font(.headline)

            ScrollView {
                VStack(spacing: 16) {
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
            }

            Spacer()

            Button(action: {
                navigateToFinal = true
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(appState.selectedPackage != nil ? Color.gray.opacity(0.3) : Color.gray.opacity(0.15))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(appState.selectedPackage == nil)
        }
        .padding()
        .navigationTitle("Packages")
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
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(package.name)
                        .font(.headline)

                    Spacer()

                    if package.recommended {
                        Text("Recommended")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(4)
                    }
                }

                Text(package.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(String(format: "$%.2f", package.price))
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.gray.opacity(0.2) : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.gray : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PackageSelectionView()
            .environmentObject(AppState())
    }
}
