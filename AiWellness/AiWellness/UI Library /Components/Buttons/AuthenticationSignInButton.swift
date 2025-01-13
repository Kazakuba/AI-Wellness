//
//  AuthenticationButton.swift
//  AiWellness
//
//  Created by Lucija Iglič on 2. 1. 25.
//

import SwiftUI

struct AuthenticationSignInButton: View {
    var image: String
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
        HStack {
            Image(systemName: image) // Replace with custom icons
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Color.buttonBackground)
        .cornerRadius(10)
    }
}
}

#Preview {
    AuthenticationSignInButton(image: "globe", text: "Continue with Google", action: {})
}
