import SwiftUI
import Domain
import DesignSystem

public struct FormView: View {
	@EnvironmentObject var appState: AppState
	@State private var navigateToPreview = false
	@State private var relationText = ""
	@State private var detailsText = ""
	@State private var selectedStyle: WishStyle = .classic

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
						text: $relationText
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
							if detailsText.isEmpty {
								Text("Np. wspólne wspomnienia, charakter, pasje...")
									.font(.system(size: 17))
									.foregroundStyle(Color(.placeholderText))
									.padding(.horizontal, 18)
									.padding(.vertical, 16)
							}
							
							TextEditor(text: $detailsText)
								.font(.system(size: 17))
								.scrollContentBackground(.hidden)
								.padding(.horizontal, 14)
								.padding(.vertical, 12)
								.background(Color.clear)
								.focused($isDetailsFocused)
						}
						
						HStack {
							Spacer()
							
							Text("\(detailsText.count)/300")
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
								isSelected: selectedStyle == style
							) {
								selectedStyle = style
							}
						}
					}
				}
				
				PrimaryButton(title: "Generuj życzenia") {
					generateWish()
				}
				.padding(.top, 8)
			}
			.padding(.horizontal, 18)
			.padding(.vertical, 18)
		}
		.background(Color.wsBackground)
		.navigationTitle("Szczegóły")
		.navigationBarTitleDisplayMode(.large)
		.navigationDestination(isPresented: $navigateToPreview) {
			GeneratedPreviewView()
		}
	}
	
	private func generateWish() {
		appState.currentForm.relation = relationText
		appState.currentForm.note = detailsText
		appState.currentForm.tone = selectedStyle.title
		
		appState.generatedText = MockWishGenerator.shared.generateMockWish(form: appState.currentForm)
		navigateToPreview = true
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
			.environmentObject(AppState())
	}
}
