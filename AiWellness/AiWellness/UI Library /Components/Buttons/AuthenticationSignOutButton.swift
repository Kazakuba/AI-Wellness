//
//  AuthenticationSignOutButton.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 1. 25.
//

import SwiftUI

struct AuthenticationSignOutButton: View {
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(5)
                    .shadow(radius: 2)
            }
        }
    }
}

#Preview {
    AuthenticationSignOutButton(text: "Sign Out", action: {})
}
