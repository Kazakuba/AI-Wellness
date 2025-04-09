//
//  NavigationRow.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct NavigationRow<Destination: View>: View {
    let icon: String
    let title: String
    let destination: Destination
    var color: Color

    var body: some View {
        NavigationLink(destination: destination) {
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
}

//#Preview {
//    NavigationRow()
//}
