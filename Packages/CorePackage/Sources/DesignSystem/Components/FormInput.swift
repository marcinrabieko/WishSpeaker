import SwiftUI

public struct FormInput: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isMultiline: Bool = false
    var keyboardType: UIKeyboardType = .default

    public init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        isMultiline: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isMultiline = isMultiline
        self.keyboardType = keyboardType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.xs) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.wsSecondaryText)

            if isMultiline {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .font(.system(size: 17))
                        .foregroundColor(.wsPrimaryText)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                        .padding(WSSpacing.sm)
                        .background(Color.wsSecondaryBackground)
                        .cornerRadius(WSRadius.button)

                    if text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 17))
                            .foregroundColor(.wsSecondaryText.opacity(0.6))
                            .padding(WSSpacing.sm)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 17))
                    .foregroundColor(.wsPrimaryText)
                    .keyboardType(keyboardType)
                    .padding(WSSpacing.sm)
                    .background(Color.wsSecondaryBackground)
                    .cornerRadius(WSRadius.button)
            }
        }
    }
}

public struct FormSection: View {
    let title: String
    let content: () -> AnyView

    public init(title: String, @ViewBuilder content: @escaping () -> some View) {
        self.title = title
        self.content = { AnyView(content()) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: WSSpacing.sm) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.wsSecondaryText)
                .textCase(.uppercase)
                .tracking(0.5)

            content()
        }
    }
}

#Preview {
    VStack(spacing: WSSpacing.md) {
        FormInput(
            label: "Recipient Name",
            placeholder: "e.g. Gregory",
            text: .constant("")
        )

        FormInput(
            label: "Note about the person",
            placeholder: "Runs a paving company, hardworking and dreams about owning a quad.",
            text: .constant(""),
            isMultiline: true
        )
    }
    .padding(.horizontal, WSSpacing.horizontalPadding)
}
