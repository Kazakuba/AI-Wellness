//
//  LoginView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 29. 12. 24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @State var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            //Cicle Image
            AIImage()
            
            //Welcome text
            WelcomeSign()
            
            //Some motivational quote for an app
            MotivationalWelcomeText()
            
            //Buttons for login
            VStack(spacing: 15) {
                AuthenticationSignInButton(image: "globe", text: "Continue with Google", action: viewModel.googleSignIn)
                AuthenticationSignInButton(image: "facebook", text: "Continue with Facebook", action: {})
                AuthenticationSignInButton(image: "envelope", text: "Continue with Email", action: {})
                AuthenticationSignInButton(image: "phone", text: "Continue with phone number", action: {})
            }
            .padding(.horizontal, 5)

            //Terms and Conditions and Privacy Policy
            TermsAndConditionsAndPrivacyPolice()
        }
        .padding()
    }
}

#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel(autheticationService: AuthenticationService()))
}

private struct AIImage: View {
    var body: some View {
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            .padding(.bottom, 20)
    }
}
private struct WelcomeSign: View {
    var body: some View {
        Text("Welcome to AI Wellness")
            .font(.title)
            .fontWeight(.semibold)
    }
}

private struct MotivationalWelcomeText: View {
    var body: some View {
        Text("Where your feelings are understood")
            .font(.subheadline)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
    }
}

private struct TermsAndConditionsAndPrivacyPolice: View {
    var body: some View {
        VStack(spacing: -10) {
            HStack {
                Text("By signing up you agree to our")
                TertiaryButton(title: "Terms and Conditions", action: {})
            }
            .font(Typography.Font.body2)

            
            HStack {
                Text("See how we use your data in our")
                TertiaryButton(title: "Privacy Policy", action: {})
            }
            .font(Typography.Font.body2)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 20)
    }
}
