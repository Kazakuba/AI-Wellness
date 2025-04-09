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

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(title)
                .foregroundColor(.primary)
        }
    }
}

//#Preview {
//    SettingsRow()
//}
