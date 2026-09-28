import SwiftUI

// MARK: - Colors

public extension Color {
    static let wsAccent = Color(hex: "6B5CFF")
    static let wsAccentLight = Color(hex: "8A7CFF")
    static let wsBackground = Color(hex: "FFF8EB")
    static let wsSecondaryBackground = Color(.systemGray6)
    static let wsPrimaryText = Color(hex: "171412")
    static let wsSecondaryText = Color(hex: "746F69")
    static let wsCardBorder = Color(hex: "EDE5D9")

    // Warm palette additions
    static let wsSurface = Color(hex: "FFFCF7") // Paper
    static let wsPrimary = Color(hex: "E50918") // Ribbon Red
    static let wsPrimaryPressed = Color(hex: "C90816")
    static let wsInk = Color(hex: "171412")
    static let wsWarmGray = Color(hex: "746F69")
    static let wsSoftBorder = Color(hex: "EDE5D9")
    static let wsWarmGold = Color(hex: "E9A23B")
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradients

// Note: Avoid gradients in new warm design; kept for legacy screens.
public struct WSGradient {
    public static let accent = LinearGradient(
        colors: [Color(hex: "6B5CFF"), Color(hex: "8A7CFF")],
        startPoint: .leading,
        endPoint: .trailing
    )

    public static let accentVertical = LinearGradient(
        colors: [Color(hex: "6B5CFF"), Color(hex: "8A7CFF")],
        startPoint: .top,
        endPoint: .bottom
    )

	public static let sceneVertical = LinearGradient(
		colors: [.white, Color(hex: "8A7CFF").opacity(0.2)],
		startPoint: .top,
		endPoint: .bottom
	)
}

// MARK: - Spacing

public enum WSSpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 16
    public static let md: CGFloat = 24
    public static let lg: CGFloat = 32
    public static let xl: CGFloat = 48

    public static let horizontalPadding: CGFloat = 24
}

// MARK: - Corner Radius

public enum WSRadius {
    public static let card: CGFloat = 20
    public static let button: CGFloat = 16
}

// MARK: - Button Height

public enum WSSize {
    public static let buttonHeight: CGFloat = 56
    public static let minTapTarget: CGFloat = 44
    public static let playButtonSize: CGFloat = 64
}
// MARK: - Typography

public enum WSFont {
    // Brand title style using New York Semibold. Keep size flexible for reuse.
    public static func brandTitle(size: CGFloat = 34) -> Font {
        Font.custom("NewYork-Semibold", size: size)
    }
}

