//
//  ComponentPreviews.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct ComponentPreviews: View {
    @State private var textInput = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Buttons
                Text("Buttons")
                    .font(Typography.Font.heading2)
                    .foregroundColor(Color(.label))
                
                PrimaryButton(title: "Primary Button") {
                    print("Primary Button tapped")
                }
                
                SecondaryButton(title: "Secondary Button") {
                    print("Secondary Button tapped")
                }
                
                TertiaryButton(title: "Tertiary Button") {
                    print("Tertiary Button tapped")
                }
                
                IconButton(icon: "heart.fill", title: "Favorite") {
                    print("Icon Button with Text tapped")
                }
                
                IconButton(icon: "trash", title: nil) {
                    print("Icon-Only Button tapped")
                }
                
                // MARK: - Text Fields
                Text("Text Fields")
                    .font(Typography.Font.heading2)
                    .foregroundColor(Color(.label))
                
                TextFieldComponent(text: $textInput, placeholder: "Enter something")
                    .padding()
                
                // MARK: - Dividers
                
                VStack {
                    Text("Above Divider")
                    CustomDivider()
                    Text("Below Divider")
                }
                
                // MARK: - Images
                Text("Images")
                    .font(Typography.Font.heading2)
                    .foregroundColor(Color(.label))
                
                RoundedImageView(
                    image: Image(systemName: "photo"),
                    placeholder: Image(systemName: "photo.fill"),
                    isLoaded: true
                )
                .frame(width: 100, height: 100)
                
                RoundedImageView(
                    image: Image(systemName: "photo"),
                    placeholder: Image(systemName: "photo.fill"),
                    isLoaded: false
                )
                .frame(width: 100, height: 100)
            }
            .padding()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

// MARK: - Previews
struct ComponentPreviews_Previews: PreviewProvider {
    static var previews: some View {
        ComponentPreviews()
    }
}
