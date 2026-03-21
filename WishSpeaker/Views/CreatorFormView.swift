import SwiftUI

struct CreatorFormView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigateToPreview = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Recipient Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recipient Name")
                        .font(.subheadline)
                    TextField("e.g. Gregory", text: $appState.currentForm.recipientName)
                        .textFieldStyle(.roundedBorder)
                }

                // Occasion
                VStack(alignment: .leading, spacing: 4) {
                    Text("Occasion")
                        .font(.subheadline)
                    TextField("e.g. Birthday", text: $appState.currentForm.occasion)
                        .textFieldStyle(.roundedBorder)
                }

                // Age (optional)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Age (optional)")
                        .font(.subheadline)
                    TextField("e.g. 40", text: $appState.currentForm.age)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }

                // Tone
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tone")
                        .font(.subheadline)
                    TextField("e.g. Funny", text: $appState.currentForm.tone)
                        .textFieldStyle(.roundedBorder)
                }

                // From
                VStack(alignment: .leading, spacing: 4) {
                    Text("From")
                        .font(.subheadline)
                    TextField("e.g. Marcin", text: $appState.currentForm.fromPerson)
                        .textFieldStyle(.roundedBorder)
                }

                // Relation
                VStack(alignment: .leading, spacing: 4) {
                    Text("Relation")
                        .font(.subheadline)
                    TextField("e.g. Brother-in-law", text: $appState.currentForm.relation)
                        .textFieldStyle(.roundedBorder)
                }

                // Note about the person
                VStack(alignment: .leading, spacing: 4) {
                    Text("Note about the person")
                        .font(.subheadline)
                    TextEditor(text: $appState.currentForm.note)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if appState.currentForm.note.isEmpty {
                                    Text("e.g. Runs a paving company, hardworking and dreams about owning a quad.")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }

                // Voice selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Voice")
                        .font(.subheadline)

                    HStack(spacing: 12) {
                        Button(action: {
                            appState.currentForm.voiceGender = .male
                        }) {
                            Text("Male Voice")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(appState.currentForm.voiceGender == .male ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            appState.currentForm.voiceGender = .female
                        }) {
                            Text("Female Voice")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(appState.currentForm.voiceGender == .female ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Generate button
                Button(action: generateWish) {
                    Text("Generate Wishes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Create Wish")
        .navigationDestination(isPresented: $navigateToPreview) {
            GeneratedPreviewView()
        }
    }

    private func generateWish() {
        appState.generatedText = MockWishGenerator.shared.generateMockWish(form: appState.currentForm)
        navigateToPreview = true
    }
}

#Preview {
    NavigationStack {
        CreatorFormView()
            .environmentObject(AppState())
    }
}
