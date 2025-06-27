//
//  LoginView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 29. 12. 24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Lottie

struct AuthenticationView: View {
    @State var viewModel: AuthenticationViewModel
    @State private var animateBG = false

    var body: some View {
        ZStack {
            AnimatedNeonBackgroundAuth(isDarkMode: false, animate: $animateBG)
                .ignoresSafeArea()
                .onAppear {
                    animateBG.toggle()
                }
            VStack {
                Spacer()
                LottieView(animation: .named("loginScreenAnimation"))
                    .playing()
                    .looping()
                    .frame(width: 300, height: 300)
                    .padding(.bottom, 20)

                //Welcome text
                WelcomeSign()

                //Some motivational quote for an app
                MotivationalWelcomeText()

                //Buttons for login
                VStack(spacing: 15) {
                    AuthenticationSignInButton(image: "globe", text: "Continue with Google", action: viewModel.googleSignIn)
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 8)

                //Terms and Conditions and Privacy Policy
                TermsAndConditionsAndPrivacyPolice()
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
    }
}

extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        #else
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        #endif
        return (Double(r), Double(g), Double(b))
    }
}

#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel(autheticationService: AuthenticationService()))
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
            .foregroundColor(Color(.secondaryLabel))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
    }
}

extension View {
    func neonButtonBackground() -> some View {
        self.background(
            LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}

struct AuthenticationSignInButton: View {
    var image: String
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: image)
                    .foregroundColor(.white)
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .neonButtonBackground()
            .cornerRadius(10)
        }
    }
}

struct AnimatedNeonBackgroundAuth: View {
    var isDarkMode: Bool
    @Binding var animate: Bool
    @State private var animateGradient = false
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: animate ? [Color.cyan, Color.purple, Color.blue, Color.mint] : [ColorPalette.background, ColorPalette.surface]),
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .animation(Animation.linear(duration: 6).repeatForever(autoreverses: true), value: animate)
    }
}

private struct TermsAndConditionsAndPrivacyPolice: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("By signing up you agree to our")
                    .font(Typography.Font.body2)
                Link("Terms & Conditions", destination: URL(string: "https://your-terms-url.com")!)
                    .font(Typography.Font.body2)
                    .foregroundColor(.blue)
                    .underline()
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 2)
            HStack(spacing: 4) {
                Text("Check how we use your data")
                    .font(Typography.Font.body2)
                Link("Privacy Policy", destination: URL(string: "https://your-privacy-url.com")!)
                    .font(Typography.Font.body2)
                    .foregroundColor(.blue)
                    .underline()
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
}
