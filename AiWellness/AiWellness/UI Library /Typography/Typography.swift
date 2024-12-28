//
//  Typography.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct Typography {
    struct Font {
        // Headings
        static let heading1 = SwiftUI.Font.system(size: 32, weight: .bold)
        static let heading2 = SwiftUI.Font.system(size: 24, weight: .semibold)
        static let heading3 = SwiftUI.Font.system(size: 20, weight: .medium)

        // Body
        static let body1 = SwiftUI.Font.system(size: 16, weight: .regular)
        static let body2 = SwiftUI.Font.system(size: 14, weight: .regular)

        // Subtitles
        static let subtitle = SwiftUI.Font.system(size: 12, weight: .regular)

        // Captions
        static let caption = SwiftUI.Font.system(size: 10, weight: .light)

        // Button Text
        static let button = SwiftUI.Font.system(size: 16, weight: .semibold)
    }
}

// Example Usage
struct TypographyExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heading 1")
                .font(Typography.Font.heading1)
            Text("Body Text 1")
                .font(Typography.Font.body1)
            Text("Caption Text")
                .font(Typography.Font.caption)
            Button("Button") {}
                .font(Typography.Font.button)
        }
        .padding()
    }
}

#Preview {
    TypographyExample()
}
