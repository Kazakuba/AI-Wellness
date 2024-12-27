//
//  TextFieldComponent.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct TextFieldComponent: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(ColorPalette.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ColorPalette.Borders.light, lineWidth: 1)
            )
            .font(Typography.Font.body1)
    }
}

// Example Usage:
struct TextFieldComponent_Previews: PreviewProvider {
    @State static var inputText: String = ""

    static var previews: some View {
        TextFieldComponent(text: $inputText, placeholder: "Enter your text")
            .padding()
    }
}