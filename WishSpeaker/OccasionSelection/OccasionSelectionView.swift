import SwiftUI

struct OccasionSelectionView: View {

	@State private var viewModel = OccasionSelectionViewModel()
	@State private var navigateToCreator = false
    @Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			ScrollView(showsIndicators: false) {
				VStack(spacing: 18) {
                    Text("Dla kogo przygotowujesz życzenia?")
                        .font(.system(size: 17))
                        .foregroundColor(.wsSecondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
					
					LazyVStack(spacing: 8) {
						ForEach(viewModel.occasions) { occasion in
							OccasionRowView(occasion: occasion) {
								navigateToCreator = true
							}
						}
					}
				}
				.padding(.horizontal, WSSpacing.horizontalPadding)
				.padding(.bottom, WSSpacing.lg)
			}
			.background(Color.wsBackground)
			.navigationTitle("Wybierz okazję")
			.navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
                        dismiss()
                    } label: {
						Image(systemName: "chevron.left")
							.font(.system(size: 17, weight: .semibold))
							.foregroundColor(.wsPrimaryText)
							.frame(width: 44, height: 44)
					}
				}
			}
			.navigationDestination(isPresented: $navigateToCreator) {
				FormView()
			}
		}
	}
}

private struct OccasionRowView: View {
	let occasion: Occasion
	let didTap: () -> Void
	
	init(occasion: Occasion, didTap: @escaping () -> Void) {
		self.occasion = occasion
		self.didTap = didTap
	}
    
    private func symbolName(for occasion: Occasion) -> String {
        let title = occasion.title.lowercased()
        // Urodziny / Imieniny
        if title.contains("urodz") { return "birthday.cake.fill" } // prefer cake, fallback to gift
        if title.contains("imien") { return "gift.fill" }
        // Ślub
        if title.contains("ślub") || title.contains("slub") { return "heart.fill" }
        // Rocznica
        if title.contains("rocznic") { return "heart.circle.fill" }
        // Dzień Matki / Ojca / Kobiet
        if title.contains("matk") { return "camera.macro" }
        if title.contains("ojc") { return "mustache.fill" }
        if title.contains("kobiet") { return "leaf.fill" } // flower-like stand-in
        // Gratulacje
        if title.contains("grat") { return "trophy.fill" }
        // Podziękowania
        if title.contains("dzi") && title.contains("kuj") { return "hands.clap.fill" }
        if title.contains("podzięk") || title.contains("podziek") { return "hands.clap.fill" }
        // Przeprosiny
        if title.contains("przepro") { return "hand.raised.fill" }
        // Święta / Nowy Rok
        if title.contains("święta") || title.contains("swieta") { return "snowflake" }
        if title.contains("nowy rok") { return "sparkles" }
        // Fallback
        return "sparkles"
    }
	
	var body: some View {
		Button {
			didTap()
		} label: {
			HStack(spacing: WSSpacing.sm) {
				ZStack {
					RoundedRectangle(cornerRadius: 12, style: .continuous)
						.fill(Color.wsPrimary.opacity(0.08))
						.frame(width: 44, height: 44)
					Image(systemName: symbolName(for: occasion))
						.font(.system(size: 20, weight: .semibold))
						.foregroundColor(.wsPrimary)
				}

				VStack(alignment: .leading, spacing: 4) {
					Text(occasion.title)
						.font(.system(size: 17, weight: .semibold))
						.foregroundColor(.wsPrimaryText)

					Text(occasion.subtitle)
						.font(.system(size: 15))
						.foregroundColor(.wsSecondaryText)
						.lineLimit(2)
				}

				Spacer()

				Image(systemName: "chevron.right")
					.font(.system(size: 13, weight: .semibold))
					.foregroundColor(.wsSecondaryText)
			}
			.padding(.horizontal, 16)
			.frame(height: 70)
			.background(Color.wsSurface)
			.overlay(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.stroke(Color.wsSoftBorder.opacity(0.8), lineWidth: 1)
			)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	OccasionSelectionView()
}

