//
//  ToggleRow.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    var color: Color

    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .scaleEffect(iconScale) // Apply scale effect
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isOn) // Animate when toggled
          
            Toggle(title, isOn: $isOn)
                .onChange(of: isOn) {
                    iconScale = 1.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation { iconScale = 1.0 }
                    }
                }
        }
    }
}

//#Preview {
//    ToggleRow()
//}
