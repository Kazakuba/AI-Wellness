//
//  NotificationReminderPromptView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 11. 6. 25.
//

import SwiftUI

struct NotificationReminderPromptView: View {
    var onSettingsTap: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Don't Miss Your Capsule!")
                .font(.title2)
                .bold()

            Text("To be reminded when your note unlocks, please enable notifications.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 20) {
                Button("Not Now") {
                    onDismiss()
                }
                .foregroundColor(.gray)

                Button("Enable Notifications") {
                    onSettingsTap()
                }
                .bold()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 8)
        )
        .padding()
    }
}

#Preview {
    NotificationReminderPromptView(
        onSettingsTap: {
            print("Open Settings tapped")
        },
        onDismiss: {
            print("Dismiss tapped")
        }
    )
}
