import SwiftUI

struct ThemeLibrary {
    static let defaultTheme = Theme(
        id: "plain",
        name: "Plain",
        colors: [ColorCodable(Color(red: 1.0, green: 0.95, blue: 0.95)), ColorCodable(Color(red: 1.0, green: 0.92, blue: 0.88))],
        category: .all,
        isDark: false
    )
    static let allThemes: [Theme] = [
        Theme(
            id: "plain",
            name: "Plain",
            colors: [ColorCodable(Color(red: 1.0, green: 0.95, blue: 0.95)), ColorCodable(Color(red: 1.0, green: 0.92, blue: 0.88))],
            category: .all,
            isDark: false
        ),
        Theme(
            id: "flower-frames",
            name: "Flower Frames",
            colors: [ColorCodable(.pink), ColorCodable(.black)],
            category: .seasonal,
            isDark: true
        ),
        Theme(
            id: "ocean",
            name: "Ocean",
            colors: [ColorCodable(.blue), ColorCodable(.cyan)],
            category: .free,
            isDark: true
        ),
        Theme(
            id: "sunset",
            name: "Sunset",
            colors: [ColorCodable(.orange), ColorCodable(.pink)],
            category: .new,
            isDark: false
        ),
        Theme(
            id: "for-you-1",
            name: "I am",
            colors: [ColorCodable(.blue), ColorCodable(.gray)],
            category: .forYou,
            isDark: true
        ),
        Theme(
            id: "for-you-2",
            name: "I am",
            colors: [ColorCodable(.black), ColorCodable(.gray)],
            category: .forYou,
            isDark: true
        )
    ]
}
