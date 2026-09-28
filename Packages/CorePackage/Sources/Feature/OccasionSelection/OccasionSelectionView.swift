import DesignSystem
import Domain
import SwiftUI

@MainActor
@Observable
final class OccasionSelectionViewModel {
	let occasions: [Occasion] = [
		Occasion(iconName: "birthday.cake", title: "Urodziny", subtitle: "Dla solenizanta lub solenizantki"),
		Occasion(iconName: "heart.circle", title: "Rocznica", subtitle: "Dla par, małżonków, związku"),
		Occasion(iconName: "gift.fill", title: "Imieniny", subtitle: "Klasyczne imieninowe życzenia"),
		Occasion(iconName: "heart.fill", title: "Ślub", subtitle: "Dla nowożeńców i zakochanych"),
		Occasion(iconName: "camera.macro", title: "Dzień Matki", subtitle: "Pokaż, jak bardzo cenisz"),
		Occasion(iconName: "mustache", title: "Dzień Ojca", subtitle: "Podziękuj swojemu tacie"),
		Occasion(iconName: "leaf.fill", title: "Dzień Kobiet", subtitle: "Dla wyjątkowej kobiety"),
		Occasion(iconName: "trophy.fill", title: "Gratulacje", subtitle: "Na nową pracę, sukces, awans"),
		Occasion(iconName: "hand.raised.fill", title: "Przeprosiny", subtitle: "Powiedz to w dobry sposób"),
		Occasion(iconName: "hands.clap.fill", title: "Podziękowania", subtitle: "Za pomoc, wsparcie lub obecność"),
		Occasion(iconName: "sparkles", title: "Inna okazja", subtitle: "Stwórz własne życzenia")
	]

	fileprivate var navigateToCreator = false

	func didSelectOccasion(_ occasion: Occasion) {
		navigateToCreator = true
	}
}

public struct OccasionSelectionView: View {

	@State private var viewModel = OccasionSelectionViewModel()
	@Environment(\.dismiss) private var dismiss

	public init() {}

	public var body: some View {
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
								viewModel.didSelectOccasion(occasion)
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
			.navigationDestination(isPresented: $viewModel.navigateToCreator) {
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
			HStack(spacing: WSSpacing.sm) {
				ZStack {
					RoundedRectangle(cornerRadius: 12, style: .continuous)
						.fill(Color.wsPrimary.opacity(0.08))
						.frame(width: 44, height: 44)
					Image(systemName: occasion.iconName)
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
