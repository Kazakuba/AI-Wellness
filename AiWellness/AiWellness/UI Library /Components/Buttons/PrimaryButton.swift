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
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.buttonBackground)
                .cornerRadius(8)
        }
    }
}

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
