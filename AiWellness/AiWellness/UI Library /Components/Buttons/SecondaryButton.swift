//
//  SecondaryButton.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.Font.button)
                .foregroundColor(ColorPalette.CustomSecondary)
                .padding()
                .frame(maxWidth: .infinity)
        }
        .background(ColorPalette.surface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorPalette.CustomSecondary, lineWidth: 2)
        )
    }
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryButton(title: "Cancel") {
            print("Secondary Button tapped")
        }
        PrimaryButton(title: "Primary Button") {
            print("Primary Button tapped")
        }
        
        .padding()
    }
}
