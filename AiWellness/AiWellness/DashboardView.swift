//
//  WelcomeScreen.swift
//  AiWellness
//
//  Created by Lucija Iglič on 27. 12. 24.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            ExampleImage()
            VStack {
                HStack {
                    WelcomeText()
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct WelcomeText: View {
    var body: some View {
        Text("Welcome [User]")
            .font(Typography.Font.heading1)
            .foregroundColor(ColorPalette.Text.white)
    }
}
struct ExampleImage: View {
    var body: some View {
        Image("exampleImage")
            .resizable()
            .ignoresSafeArea()
            .opacity(0.9)
    }
}

#Preview {
    DashboardView()
}
