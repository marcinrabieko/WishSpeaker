import SwiftUI
import Domain
import DesignSystem
import Dependencies

@MainActor
@Observable
public final class FormViewModel {
	fileprivate var relationText = ""
	fileprivate var detailsText = ""
	fileprivate var selectedStyle: WishStyle = .classic
	fileprivate var navigateToPreview = false

	@ObservationIgnored
	@Dependency(\.wishCreationManager)
	private var creationManager: WishCreationManager

	public init() {}

	func didSelectStyle(_ style: WishStyle) {
		selectedStyle = style
	}

	func didTapGenerate() {
		creationManager.currentForm.relation = relationText
		creationManager.currentForm.note = detailsText
		creationManager.currentForm.tone = selectedStyle.title

		creationManager.generatedText = MockWishGenerator.shared.generateMockWish(form: creationManager.currentForm)
		navigateToPreview = true
	}
}

public struct FormView: View {
	@State private var viewModel = FormViewModel()

	@FocusState private var isRelationFocused: Bool
	@FocusState private var isDetailsFocused: Bool

	public init() {}

	public var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: 28) {
				VStack(alignment: .leading, spacing: 12) {
					Text("Dla kogo są życzenia?")
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(Color.wsPrimaryText)

					TextField(
						"Np. dla siostry, najlepszego przyjaciela, męża...",
						text: $viewModel.relationText
					)
					.font(.system(size: 17))
					.padding(.horizontal, 18)
					.frame(height: 58)
					.background(Color.wsSurface)
					.overlay {
						RoundedRectangle(cornerRadius: 18, style: .continuous)
							.stroke(isRelationFocused ? Color.wsPrimary : Color.wsSoftBorder, lineWidth: isRelationFocused ? 2 : 1)
					}
					.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
					.focused($isRelationFocused)
				}

				VStack(alignment: .leading, spacing: 8) {
					Text("Opowiedz coś o tej osobie")
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(Color.wsPrimaryText)
					Text("Opcjonalnie, ale pomoże nam stworzyć bardziej osobiste życzenia.")
						.font(.system(size: 14))
						.foregroundStyle(Color.wsSecondaryText)

					VStack(alignment: .leading, spacing: 0) {
						ZStack(alignment: .topLeading) {
							if viewModel.detailsText.isEmpty {
								Text("Np. wspólne wspomnienia, charakter, pasje...")
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
							.stroke(isDetailsFocused ? Color.wsPrimary : Color.wsSoftBorder, lineWidth: isDetailsFocused ? 2 : 1)
					}
					.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
				}

				VStack(alignment: .leading, spacing: 16) {
					Text("Styl życzeń")
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(Color.wsPrimaryText)

					LazyVGrid(
						columns: [
							GridItem(.flexible()),
							GridItem(.flexible()),
							GridItem(.flexible())
						],
						spacing: 12
					) {
						ForEach(WishStyle.allCases, id: \.self) { style in
							StyleChip(
								title: style.title,
								isSelected: viewModel.selectedStyle == style
							) {
								viewModel.didSelectStyle(style)
							}
						}
					}
				}

				PrimaryButton(title: "Generuj życzenia") {
					viewModel.didTapGenerate()
				}
				.padding(.top, 8)
			}
			.padding(.horizontal, 18)
			.padding(.vertical, 18)
		}
		.background(Color.wsBackground)
		.navigationTitle("Szczegóły")
		.navigationBarTitleDisplayMode(.large)
		.navigationDestination(isPresented: $viewModel.navigateToPreview) {
			GeneratedPreviewView()
		}
	}
}

private struct StyleChip: View {
	let title: String
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text(title)
				.font(.system(size: 15, weight: .semibold))
				.foregroundStyle(isSelected ? Color.wsPrimary : Color.wsPrimaryText)
				.frame(maxWidth: .infinity)
				.frame(height: 46)
				.background(isSelected ? Color.wsPrimary.opacity(0.06) : Color.wsSurface)
				.overlay {
					RoundedRectangle(cornerRadius: 16, style: .continuous)
						.stroke(
							isSelected
								? Color.wsPrimary
								: Color.wsSoftBorder,
							lineWidth: isSelected ? 2 : 1
						)
				}
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	NavigationStack {
		FormView()
	}
}
