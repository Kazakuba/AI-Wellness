//
//  AffirmationsSettingsView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct AffirmationsSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        List {
            // Affirmation Preferences
            Section(header: Text("Affirmation Preferences").foregroundColor(isDarkMode ? .white : .black)) {
                NavigationRow(icon: "camera.macro.circle", title: "Select Affirmation Types", destination: AffirmationTypesView(), color: .gray)
                NavigationRow(icon: "clock.arrow.trianglehead.counterclockwise.rotate.90", title: "Set Delivery Time", destination: DeliveryTimeView(), color: .yellow)
            }
            
            //Visual & Interaction Settings
            Section (header: Text("Visual & Interaction Settings").foregroundColor(isDarkMode ? .white : .black)) {
                ToggleRow(icon: "circle.dotted.and.circle", title: "Enable Animation", isOn:  $viewModel.enableAffirmationAnimations, color: .purple)
                ToggleRow(icon: "circle.dotted", title: "Enable Motion Effects", isOn: $viewModel.enableMotionEffects, color: .mint)
            }
        }
        .navigationTitle("Affirmations")
        .foregroundColor(isDarkMode ? .white : .black)
        .background(isDarkMode ? Color.black : Color.white)
        .scrollContentBackground(.hidden)
        .toolbarBackground(isDarkMode ? Color.black : Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        .tint(isDarkMode ? .white : .black)
    }
}
#Preview {
    let sharedAuthService = AuthenticationService()
    AffirmationsSettingsView(viewModel: SettingsViewModel(authService: sharedAuthService))
        .environmentObject(SettingsViewModel(authService: sharedAuthService))
}

struct AffirmationTypesView: View {
    var body: some View {
        Text("Choose specific types of affirmations (Coming Soon)")
    }
}

