import SwiftUI

struct CreatorFormView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToPreview = false

    var body: some View {
        ScrollView {
            VStack(spacing: WSSpacing.lg) {
                // Recipient Section
                FormSection(title: "Recipient") {
                    VStack(spacing: WSSpacing.sm) {
                        FormInput(
                            label: "Recipient Name",
                            placeholder: "e.g. Gregory",
                            text: $appState.currentForm.recipientName
                        )

                        FormInput(
                            label: "Occasion",
                            placeholder: "e.g. Birthday",
                            text: $appState.currentForm.occasion
                        )

                        FormInput(
                            label: "Age (optional)",
                            placeholder: "e.g. 40",
                            text: $appState.currentForm.age,
                            keyboardType: .numberPad
                        )
                    }
                }

                // Context Section
                FormSection(title: "Context") {
                    VStack(spacing: WSSpacing.sm) {
                        FormInput(
                            label: "Tone",
                            placeholder: "e.g. Funny",
                            text: $appState.currentForm.tone
                        )

                        FormInput(
                            label: "Relation",
                            placeholder: "e.g. Brother-in-law",
                            text: $appState.currentForm.relation
                        )

                        FormInput(
                            label: "From",
                            placeholder: "e.g. Marcin",
                            text: $appState.currentForm.fromPerson
                        )
                    }
                }

                // About Section
                FormSection(title: "About the Person") {
                    FormInput(
                        label: "Note about the person",
                        placeholder: "Runs a paving company, hardworking and dreams about owning a quad.",
                        text: $appState.currentForm.note,
                        isMultiline: true
                    )
                }

                // Voice Selection
                FormSection(title: "Voice") {
                    VoiceSelector(selectedGender: $appState.currentForm.voiceGender)
                }

                // Generate Button
                PrimaryButton(title: "Generate Wish") {
                    generateWish()
                }
                .padding(.top, WSSpacing.sm)
            }
            .padding(.horizontal, WSSpacing.horizontalPadding)
            .padding(.vertical, WSSpacing.md)
        }
        .background(Color.wsBackground)
        .navigationTitle("Create Wish")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $navigateToPreview) {
            GeneratedPreviewView()
        }
    }

    private func generateWish() {
        appState.generatedText = MockWishGenerator.shared.generateMockWish(form: appState.currentForm)
        navigateToPreview = true
    }
}

struct VoiceSelector: View {
    @Binding var selectedGender: VoiceGender

    var body: some View {
        HStack(spacing: WSSpacing.sm) {
            VoiceOption(
                title: "Male",
                icon: "person.fill",
                isSelected: selectedGender == .male
            ) {
                selectedGender = .male
            }

            VoiceOption(
                title: "Female",
                icon: "person.fill",
                isSelected: selectedGender == .female
            ) {
                selectedGender = .female
            }
        }
    }
}

struct VoiceOption: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: WSSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WSSpacing.sm)
            .foregroundColor(isSelected ? .white : .wsPrimaryText)
            .background(
                Group {
                    if isSelected {
                        WSGradient.accent
                    } else {
                        LinearGradient(colors: [Color(.systemGray5)], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .cornerRadius(WSRadius.button)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    NavigationStack {
        CreatorFormView()
            .environmentObject(AppState())
    }
}
