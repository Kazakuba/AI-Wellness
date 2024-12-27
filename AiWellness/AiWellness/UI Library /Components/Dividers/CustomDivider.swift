//
//  CustomDivider.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(ColorPalette.Borders.light)
            .padding(.horizontal)
    }
}

// Example Usage:
struct CustomDivider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Above Divider")
            CustomDivider()
            Text("Below Divider")
        }
        .padding()
    }
}