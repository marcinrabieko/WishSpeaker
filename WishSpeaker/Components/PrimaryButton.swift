import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: WSSize.buttonHeight)
                .background(
                    Group {
                        if isEnabled {
                            WSGradient.accent
                        } else {
                            LinearGradient(
                                colors: [Color.wsAccent.opacity(0.5), Color.wsAccentLight.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(WSRadius.button)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: WSSpacing.sm) {
        PrimaryButton(title: "Create a Wish") {}
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding(.horizontal, WSSpacing.horizontalPadding)
}
