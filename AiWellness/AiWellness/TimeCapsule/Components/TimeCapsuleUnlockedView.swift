//
//  TimeCapsuleUnlockedView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 5. 6. 25.
//

import SwiftUI

struct TimeCapsuleUnlockedView: View {
    let note: TimeCapsuleNote
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Time Capsule")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(note.content)
                .font(.title2)
                .padding()
                .multilineTextAlignment(.center)
            
            Text("Unlocked on \(note.unlockDate, formatter: DateFormatter.short)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .background(LinearGradient(
            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(20)
        .padding()
    }
}

#Preview {
    TimeCapsuleUnlockedView(note: TimeCapsuleNote(
        id: UUID(),
        content: "This is a test note from the past.",
        unlockDate: Date()
    ))
}
