import DesignSystem
import Domain
import FormFeature
import Localizations
import SwiftUI

public struct OccasionSelectionView: View {

	@State private var viewModel = OccasionSelectionViewModel()
	@Environment(\.createFlowPath) private var createFlowPath

	public init() {}

	public var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: 18) {
				Text(L10n.occasionSelectionQuestion)
					.font(.system(size: 17))
					.foregroundColor(.wsSecondaryText)
					.frame(maxWidth: .infinity, alignment: .leading)

				LazyVStack(spacing: 8) {
					ForEach(viewModel.occasions) { occasion in
						OccasionRowView(occasion: occasion) {
							viewModel.didSelectOccasion(occasion, path: createFlowPath)
						}
					}
				}
			}
			.padding(.horizontal, WSSpacing.horizontalPadding)
			.padding(.bottom, WSSpacing.lg)
		}
		.background(Color.wsBackground)
		.navigationTitle(L10n.occasionSelectionTitle)
		.navigationBarTitleDisplayMode(.large)
		.wsBackButton()
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
