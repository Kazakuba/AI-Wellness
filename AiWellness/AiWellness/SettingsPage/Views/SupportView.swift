//
//  SupportView.swift
//  AiWellness
//
//  Created by Kazakuba on 10. 3. 25.
//

import SwiftUI

struct SupportView: View {
    @StateObject var viewModel = SupportViewModel()
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        List {
            // Legal & Help Section
            Section(header: Text("Legal & Help").foregroundColor(isDarkMode ? .white : .black)) {
                Button(action: {
                    if let url = URL(string: "https://www.google.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Terms of Service").foregroundColor(isDarkMode ? .white : .black)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Button(action: {
                    if let url = URL(string: "https://www.google.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Privacy Policy").foregroundColor(isDarkMode ? .white : .black)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Button(action: {
                    if let url = URL(string: "https://www.google.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Help").foregroundColor(isDarkMode ? .white : .black)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
            }
            
            // User Engagement Section
            Section(header: Text("User Engagement").foregroundColor(isDarkMode ? .white : .black)) {
                Button("Submit Feedback / Report an Issue") {
                    viewModel.sendFeedbackEmail()
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Button("Rate the App") {
                    viewModel.rateApp()
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
                Button("Share the App") {
                    viewModel.shareApp()
                }
                .foregroundColor(isDarkMode ? .white : .black)
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
            }
        }
        .navigationTitle("Support & Feedback")
        .background(AppBackgroundGradient.main(isDarkMode))
        .scrollContentBackground(.hidden)
        .toolbarBackground(isDarkMode ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Support & Feedback")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
        .tint(isDarkMode ? .white : .black)
    }
}

#Preview {
    SupportView()
}
