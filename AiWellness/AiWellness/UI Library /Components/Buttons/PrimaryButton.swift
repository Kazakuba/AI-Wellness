//
//  PrimaryButton.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.Font.button)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
        }
        .background(ColorPalette.CustomPrimary)
        .cornerRadius(8)
    }
}

// Example Usage
struct PrimaryButtonExample: View {
    var body: some View {
        PrimaryButton(title: "Submit") {
            print("Button tapped")
        }
        .padding()
    }
}

#Preview {
    PrimaryButtonExample()
}
