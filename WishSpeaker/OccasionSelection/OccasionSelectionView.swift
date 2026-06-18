import SwiftUI

struct OccasionSelectionView: View {

	@State private var viewModel = OccasionSelectionViewModel()
	
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
							OccasionRowView(occasion: occasion)
						}
					}
				}
				.padding(.horizontal, 20)
				.padding(.bottom, 32)
			}
			.background(WSGradient.sceneVertical)
			.navigationTitle("Wybierz okazję")
			.navigationBarTitleDisplayMode(.large)
		}
	}
}

private struct OccasionRowView: View {
	let occasion: Occasion
	
	var body: some View {
		Button {
			// TODO: Handle occasion selection.
		} label: {
			HStack(spacing: 18) {
				Image(occasion.iconName)
					.resizable()
					.scaledToFit()
					.frame(width: 40, height: 40)
				
				VStack(alignment: .leading, spacing: 6) {
					Text(occasion.title)
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(.primary)
					
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
