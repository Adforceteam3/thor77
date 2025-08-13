import SwiftUI

struct ThemeColors {
    static let primary = Color(hex: "004DE5")
    static let accent = Color(hex: "009DFE")
    static let deepBlue = Color(hex: "002FE1")
    static let background = Color(hex: "F3F9FD")
    
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let gray = Color.gray
    static let lightGray = Color(hex: "F5F5F7")
    static let white = Color.white
    static let black = Color.black
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
