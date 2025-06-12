//
//  IconButton.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct IconButton: View {
    let icon: String
    let title: String?
    let action: () -> Void
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : .black)
                if let title = title {
                    Text(title)
                        .font(Typography.Font.button)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
            }
            .foregroundColor(ColorPalette.CustomPrimary)
            //.padding(.horizontal, 12)
            //.padding(.vertical, 8)
            //.background(ColorPalette.surface)
            .cornerRadius(8)
        }
    }
}

// Example Usage
struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            IconButton(icon: "heart.fill", title: "Favorite") {
                print("Icon button tapped")
            }
            IconButton(icon: "trash", title: nil) {
                print("Icon-only button tapped")
            }
        }
        .padding()
    }
}
