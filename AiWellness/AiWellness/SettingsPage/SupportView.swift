//
//  SupportView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct SupportView: View {
    @StateObject var viewModel = SupportViewModel()
    
    var body: some View {
        List {
            // Legal & Help Section
            Section(header: Text("Legal & Help")) {
                NavigationLink("Terms of Service") {
                    Text("Terms of Service Content Here")
                }
                NavigationLink("Privacy Policy") {
                    Text("Privacy Policy Content Here")
                }
                NavigationLink("Help") {
                    Text("Help & Features Guide Coming Soon")
                }
            }
            
            // User Engagement Section
            Section(header: Text("User Engagement")) {
                Button("Submit Feedback / Report an Issue") {
                    viewModel.sendFeedbackEmail()
                }
                
                Button("Rate the App") {
                    viewModel.rateApp()
                }
                
                Button("Share the App") {
                    viewModel.shareApp()
                }
            }
        }
        .navigationTitle("Support & Feedback")
    }
}


#Preview {
    SupportView()
}
