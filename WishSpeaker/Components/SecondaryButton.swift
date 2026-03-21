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
                .background(Color(.systemGray5))
                .cornerRadius(WSRadius.button)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VStack(spacing: WSSpacing.sm) {
        SecondaryButton(title: "Hear Examples") {}
        SecondaryButton(title: "Generate Again") {}
    }
    .padding(.horizontal, WSSpacing.horizontalPadding)
}
