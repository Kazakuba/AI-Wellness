//
//  AccountSettingsView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct AccountSettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var body: some View {
        List {
            Section(header: Text("Account Settings").foregroundColor(isDarkMode ? .white : .black)) {
                NavigationLink(destination: Text("Email & Password Update Coming Soon").foregroundColor(isDarkMode ? .white : .black).background(isDarkMode ? Color.black : Color.white)) {
                    Text("Update Email / Password").foregroundColor(isDarkMode ? .white : .black)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color(.systemGray6))
                NavigationLink(destination: Text("Currently only Google Sign-In Available").foregroundColor(isDarkMode ? .white : .black).background(isDarkMode ? Color.black : Color.white)) {
                    Text("Link / Unlink Accounts").foregroundColor(isDarkMode ? .white : .black)
                }
                .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color(.systemGray6))
            }
        }
        .navigationTitle("Account Management")
        .background(isDarkMode ? Color.black : Color.white)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    AccountSettingsView()
}
