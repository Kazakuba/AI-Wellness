//
//  AuthenticationSignOutButton.swift
//  AiWellness
//
//  Created by Kazakuba on 10. 1. 25.
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
                    .foregroundColor(Color(.systemRed))
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(5)
                    .shadow(radius: 2)
            }
        }
    }
}

#Preview {
    AuthenticationSignOutButton(text: "Sign Out", action: {})
}
