import SwiftUI

struct Theme {
    // MARK: - Colors
    struct Colors {
        static let bg = Color(hex: "0A0A0B")
        static let surface = Color(hex: "161618")
        static let surfaceElevated = Color(hex: "1E1E21")
        static let accent = Color(hex: "FF4F00") // Electric Orange
        static let accentDim = Color(hex: "331405")
        static let textPrimary = Color(hex: "FAFAFA")
        static let textSecondary = Color(hex: "A1A1A6")
        static let destructive = Color(hex: "FF453A")
        static let success = Color(hex: "32D74B")
    }
    
    // MARK: - Typography
    struct Fonts {
        static let hero = Font.system(size: 56, weight: .bold, design: .default)
        static let h1 = Font.system(size: 34, weight: .semibold, design: .default)
        static let h2 = Font.system(size: 28, weight: .semibold, design: .default)
        static let h3 = Font.system(size: 22, weight: .medium, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let mono = Font.system(size: 17, weight: .regular, design: .monospaced)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Layout
    struct Layout {
        static let buttonHeight: CGFloat = 56
        static let cornerRadius: CGFloat = 16
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
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
