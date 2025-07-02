//
//  NavigationRow.swift
//  AiWellness
//
//  Created by Kazakuba on 10. 3. 25.
//

import SwiftUI

struct NavigationRow<Destination: View>: View {
    let icon: String
    let title: String
    let destination: Destination
    var color: Color
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30, height: 30)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(title)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
    }
}

//#Preview {
//    NavigationRow()
//}
