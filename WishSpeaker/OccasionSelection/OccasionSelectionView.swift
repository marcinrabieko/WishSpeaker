import SwiftUI

struct OccasionSelectionView: View {

	@State private var viewModel = OccasionSelectionViewModel()
	@State private var navigateToCreator = false
	
	var body: some View {
		NavigationStack {
			ScrollView(showsIndicators: false) {
				VStack(spacing: 18) {
					Text("Na jaką okazję chcesz przygotować życzenia?")
						.font(.system(size: 15, weight: .regular))
						.foregroundStyle(Color(.secondaryLabel))
						.multilineTextAlignment(.leading)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.top, 4)
					
					LazyVStack(spacing: 12) {
						ForEach(viewModel.occasions) { occasion in
							OccasionRowView(occasion: occasion) {
								navigateToCreator = true
							}
						}
					}
				}
				.padding(.horizontal, 20)
				.padding(.bottom, 32)
			}
			.background(WSGradient.sceneVertical)
			.navigationTitle("Wybierz okazję")
			.navigationBarTitleDisplayMode(.large)
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
	
	var body: some View {
		Button {
			didTap()
		} label: {
			HStack(spacing: 18) {
				Image(occasion.iconName)
					.resizable()
					.scaledToFit()
					.frame(width: 40, height: 40)
				
				VStack(alignment: .leading, spacing: 6) {
					Text(occasion.title)
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(.black)
					
					Text(occasion.subtitle)
						.font(.system(size: 15, weight: .medium))
						.foregroundStyle(.black.opacity(0.5))
						.lineLimit(2)
				}
				
				Spacer(minLength: 0)
			}
			.padding(.horizontal, 16)
			.frame(height: 68)
			.background(Color.wsAccentLight.opacity(0.09))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	OccasionSelectionView()
}
