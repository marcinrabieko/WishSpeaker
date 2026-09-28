import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    public init(title: String, action: @escaping () -> Void, isEnabled: Bool = true) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: WSSize.buttonHeight)
                .background(
                    Group {
                        if isEnabled {
                            Color.wsPrimary
                        } else {
                            Color.wsPrimary.opacity(0.5)
                        }
                    }
                )
                .cornerRadius(WSRadius.button)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
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
