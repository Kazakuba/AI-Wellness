import SwiftUI

struct Theme: Identifiable, Codable, Equatable {
    enum Category: String, Codable, CaseIterable, Identifiable {
        case all = "All"
        case free = "Free"
        case new = "New"
        case seasonal = "Seasonal"
        case forYou = "For you"
        var id: String { rawValue }
    }
    let id: String
    let name: String
    let colors: [ColorCodable]
    let category: Category
    let isDark: Bool // true = dark theme, false = light theme
    // For preview only (not persisted)
    var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: colors.map { $0.color }), startPoint: .top, endPoint: .bottom)
    }
}

// Helper to encode/decode Color
struct ColorCodable: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    var color: Color { Color(red: red, green: green, blue: blue, opacity: alpha) }
    init(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        red = Double(r); green = Double(g); blue = Double(b); alpha = Double(a)
    }
}
