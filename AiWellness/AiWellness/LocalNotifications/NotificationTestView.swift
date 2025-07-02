//
//  NotificationTestView.swift
//  AiWellness
//
//  Created by Kazakuba on 23. 4. 25.
//

import SwiftUI

struct NotificationTestView: View {
    var viewModel = NotificationService()
    @Binding var isPresented: Bool
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ? [Color.indigo, Color.black] : [Color.mint, Color.cyan]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            gradient.ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    IconButton(icon: "xmark", title: "") {
                        isPresented = false
                    }
                    Spacer()
                }
                Spacer()
                
                //Title
                Text("Test Notification")
                    .font(Typography.Font.heading2)
                    .foregroundColor(.white)
                    .padding()
                    .foregroundColor(isDarkMode ? .white : .black)
                
                // Button for notification perrmission
                RequestNotificationButton()
                
                // Button for notification test
                ScheduleNotificationButton()
                
                Spacer()
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    NotificationTestView(isPresented: .constant(true))
}


struct ScheduleNotificationButton: View {
    var body: some View {
        Button("Schedule Notification in 1 Minute") {
            // Set unlock date 1 minute from now
            let unlockDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
            
            // Create a dummy test note
            let note = TimeCapsuleNote(
                id: UUID(),
                content: "You are strong, kind and capable!",
                unlockDate: unlockDate
            )
            
            // Schedule the notification using NotificationService
            NotificationService.shared.scheduleNotification(for: note, at: note.unlockDate) { result in
                switch result {
                case .success():
                    print("Notification schedule for \(unlockDate)")
                case .failure(let error):
                    print("Failed to schedule: \(error.localizedDescription)")
                }
            }
        }
        .padding()
        .background(Color.secondary)
        .foregroundStyle(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct RequestNotificationButton: View {
    var body: some View {
        Button("Request Notification Permission") {
            NotificationService.shared.requestPermission { granted in
                if granted {
                    print("Permission granted")
                } else {
                    print("Permission denied")
                }
            }
        }
        .padding()
        .background(Color.secondary)
        .foregroundStyle(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
