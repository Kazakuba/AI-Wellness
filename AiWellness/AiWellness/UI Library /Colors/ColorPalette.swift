//
//  ColorPalette.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct ColorPalette {
    static let CustomPrimary = Color("CustomPrimary")
    static let CustomSecondary = Color("CustomSecondary")
    static let CTA = Color("CTA")
    static let background = Color("Background")
    static let surface = Color("Surface")

    struct Text {
        static let primary = Color("TextPrimary")
        static let secondary = Color("TextSecondary")
        static let disabled = Color("TextDisabled")
    }

    struct Borders {
        static let light = Color("BorderLight")
        static let dark = Color("BorderDark")
    }

    struct State {
        static let success = Color("Success")
        static let warning = Color("Warning")
        static let error = Color("Error")
        static let info = Color("Info")
    }

    struct Grayscales {
        static let gray50 = Color("Gray50")
        static let gray100 = Color("Gray100")
        static let gray200 = Color("Gray200")
    }

    static let overlay = Color.black.opacity(0.5)
}

// Example Usage, Edit colors in Assets
struct ColorPaletteExample: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Primary Color")
                .foregroundColor(ColorPalette.CustomPrimary)
            Text("Secondary Text")
                .foregroundColor(ColorPalette.Text.secondary)
        }
        .padding()
        .background(ColorPalette.background)
    }
}

#Preview {
    ColorPaletteExample()
}
