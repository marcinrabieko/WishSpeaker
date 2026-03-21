import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.wsPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: WSSize.buttonHeight)
                .background(Color.wsSecondaryBackground)
                .cornerRadius(WSRadius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: WSRadius.button)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VStack(spacing: WSSpacing.sm) {
        SecondaryButton(title: "Hear Examples") {}
    }
    .padding(.horizontal, WSSpacing.horizontalPadding)
}
