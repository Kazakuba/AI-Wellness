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
                Image(systemName: image)
                    .foregroundColor(Color(.label))
                Text(text)
                    .foregroundColor(Color(.label))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.buttonBackground)
            .cornerRadius(10)
        }
    }
}
