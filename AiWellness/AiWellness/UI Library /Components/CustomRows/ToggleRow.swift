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
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDarkMode ? .white : .black)
                .frame(width: 30, height: 30)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .scaleEffect(iconScale) // Apply scale effect
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isOn) // Animate when toggled

            Toggle(title, isOn: $isOn)
                .foregroundColor(isDarkMode ? .white : .black)
                .onChange(of: isOn) {
                    iconScale = 1.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation { iconScale = 1.0 }
                    }
                }
        }
        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
    }
}

//#Preview {
//    ToggleRow()
//}
