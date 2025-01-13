//
//  TertiaryButton.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct TertiaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.Font.button)
                .foregroundColor(ColorPalette.CustomPrimary)
                .padding(.vertical, 8)
                .underline()
        }
    }
}

// Example Usage
struct TertiaryButton_Previews: PreviewProvider {
    static var previews: some View {
        TertiaryButton(title: "Learn More") {
            print("Tertiary button tapped")
        }
        .padding()
    }
}
