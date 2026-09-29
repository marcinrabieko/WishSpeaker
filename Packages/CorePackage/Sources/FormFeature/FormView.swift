import DesignSystem
import Domain
import GeneratedPreviewFeature
import Localizations
import SwiftUI

public struct FormView: View {
	@State private var viewModel = FormViewModel()
	@Environment(\.dismiss) private var dismiss

	@FocusState private var isRelationFocused: Bool
	@FocusState private var isDetailsFocused: Bool

	public init() {}

	public var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: 28) {
				if let occasion = viewModel.selectedOccasion {
					SelectedOccasionChip(occasion: occasion) {
						dismiss()
					}
				}

				VStack(alignment: .leading, spacing: 12) {
					Text(viewModel.recipientTitle)
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(Color.wsPrimaryText)

					TextField(
						viewModel.recipientPlaceholder,
						text: $viewModel.relationText
					)
					.font(.system(size: 17))
					.padding(.horizontal, 18)
					.frame(height: 58)
					.background(Color.wsSurface)
					.overlay {
						RoundedRectangle(cornerRadius: 18, style: .continuous)
							.stroke(isRelationFocused ? Color.wsPrimary : Color.wsSoftBorder, lineWidth: 1)
					}
					.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
					.focused($isRelationFocused)
				}

				VStack(alignment: .leading, spacing: 8) {
					Text(L10n.formDetailsQuestion)
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(Color.wsPrimaryText)
					Text(L10n.formDetailsHint)
						.font(.system(size: 14))
						.foregroundStyle(Color.wsSecondaryText)

					VStack(alignment: .leading, spacing: 0) {
						ZStack(alignment: .topLeading) {
							if viewModel.detailsText.isEmpty {
								Text(viewModel.detailsPlaceholder)
									.font(.system(size: 17))
									.foregroundStyle(Color(.placeholderText))
									.padding(.horizontal, 18)
									.padding(.vertical, 16)
							}

							TextEditor(text: $viewModel.detailsText)
								.font(.system(size: 17))
								.scrollContentBackground(.hidden)
								.padding(.horizontal, 14)
								.padding(.vertical, 12)
								.background(Color.clear)
								.focused($isDetailsFocused)
						}

						HStack {
							Spacer()

							Text("\(viewModel.detailsText.count)/300")
								.font(.system(size: 14))
								.foregroundStyle(Color(.secondaryLabel))
								.padding(.trailing, 16)
								.padding(.bottom, 14)
						}
					}
					.background(Color.wsSurface)
					.overlay {
						RoundedRectangle(cornerRadius: 18, style: .continuous)
							.stroke(isDetailsFocused ? Color.wsPrimary : Color.wsSoftBorder, lineWidth: 1)
					}
					.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
				}

				PrimaryButton(title: L10n.formGenerateButton, icon: "sparkles") {
					viewModel.didTapGenerate()
				}
				.padding(.top, 24)
			}
			.padding(.horizontal, 18)
			.padding(.vertical, 18)
		}
		.background(Color.wsBackground)
		.navigationTitle(L10n.formTitle)
		.navigationBarTitleDisplayMode(.large)
		.wsBackButton()
		.navigationDestination(isPresented: $viewModel.navigateToPreview) {
			GeneratedPreviewView()
		}
		.onAppear {
			viewModel.didAppear()
		}
	}
}

private struct SelectedOccasionChip: View {
	let occasion: Occasion
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack(spacing: 6) {
				Image(systemName: occasion.iconName)
					.font(.system(size: 14, weight: .semibold))
					.foregroundStyle(Color.wsPrimary)

				Text(occasion.title)
					.font(.system(size: 15, weight: .semibold))
					.foregroundStyle(Color.wsPrimary)
			}
			.padding(.horizontal, 14)
			.padding(.vertical, 8)
			.background(Color.wsPrimary.opacity(0.1))
			.clipShape(Capsule())
		}
		.buttonStyle(.plain)
	}
}
