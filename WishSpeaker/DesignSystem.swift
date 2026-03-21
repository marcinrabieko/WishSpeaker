import SwiftUI

// MARK: - Colors

extension Color {
    static let wsAccent = Color(hex: "6B5CFF")
    static let wsBackground = Color.white
    static let wsSecondaryBackground = Color(hex: "F2F2F7")
    static let wsPrimaryText = Color(hex: "111111")
    static let wsSecondaryText = Color(hex: "6B6B6B")
}

extension Color {
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

// MARK: - Spacing

enum WSSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 16
    static let md: CGFloat = 24
    static let lg: CGFloat = 32
    static let xl: CGFloat = 48

    static let horizontalPadding: CGFloat = 24
}

// MARK: - Corner Radius

enum WSRadius {
    static let card: CGFloat = 20
    static let button: CGFloat = 16
}

// MARK: - Button Height

enum WSSize {
    static let buttonHeight: CGFloat = 56
    static let minTapTarget: CGFloat = 44
}
