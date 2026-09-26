import SwiftUI

struct FormView: View {
	@EnvironmentObject var appState: AppState
	@State private var navigateToPreview = false
	@State private var relationText = ""
	@State private var detailsText = ""
	@State private var selectedStyle: WishStyle = .classic
	
	var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: 28) {
				VStack(alignment: .leading, spacing: 12) {
					Text("Dla kogo są życzenia?")
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(.black)
					
					TextField(
						"Np. dla siostry, najlepszego przyjaciela, męża...",
						text: $relationText
					)
					.font(.system(size: 17))
					.padding(.horizontal, 18)
					.frame(height: 58)
					.background(Color.white)
					.overlay {
						RoundedRectangle(cornerRadius: 18, style: .continuous)
							.stroke(Color.black.opacity(0.08), lineWidth: 3)
					}
					.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
				}
				
				VStack(alignment: .leading, spacing: 12) {
					Text("Dodaj kilka informacji (opcjonalnie)")
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(.black)
					
					VStack(alignment: .leading, spacing: 0) {
						ZStack(alignment: .topLeading) {
							if detailsText.isEmpty {
								Text("Napisz o osobie, Waszej relacji, wspólnych wspomnieniach, pasjach...\nIm więcej napiszesz, tym lepsze życzenia przygotujemy.")
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
					.background(Color.white)
					.overlay {
						RoundedRectangle(cornerRadius: 18, style: .continuous)
							.stroke(Color.black.opacity(0.1), lineWidth: 3)
					}
					.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
				}
				
				VStack(alignment: .leading, spacing: 16) {
					Text("Styl życzeń")
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(.black)
					
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
				
				Button {
					generateWish()
				} label: {
					HStack(spacing: 10) {
						Image(systemName: "sparkles")
							.font(.system(size: 18, weight: .semibold))
						
						Text("Generuj życzenia")
							.font(.system(size: 19, weight: .semibold))
					}
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 60)
					.background(WSGradient.accent)
					.clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
				}
				.buttonStyle(.plain)
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
				.foregroundStyle(isSelected ? Color.wsAccent : Color.black)
				.frame(maxWidth: .infinity)
				.frame(height: 46)
				.background(isSelected ? Color.wsAccent.opacity(0.06) : Color.white)
				.overlay {
					RoundedRectangle(cornerRadius: 16, style: .continuous)
						.stroke(
							isSelected
							? Color.wsAccent.opacity(0.7)
							: Color.black.opacity(0.08),
							lineWidth: isSelected ? 4 : 3
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
