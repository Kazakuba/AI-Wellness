//
//  SettingsRow.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    var color: Color
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDarkMode ? .white : .black)
                .frame(width: 30, height: 30)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(title)
                .foregroundColor(isDarkMode ? .white : .black)
        }
        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color(.systemGray6))
    }
}

//#Preview {
//    SettingsRow()
//}
