//
//  SupportViewModel.swift
//  AiWellness
//
//  Created by Kazakuba on 10. 3. 25.
//

import SwiftUI

class SupportViewModel: ObservableObject {
    
    // correct email adress later !
    func sendFeedbackEmail() {
        let email = "support@yourapp.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    // correct url adress later !
    func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    func shareApp() {
        let text = "Check out this amazing app: [App Store Link]"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            
            rootVC.present(activityVC, animated: true)
        }
    }
}
