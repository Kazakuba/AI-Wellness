//
//  PickerRow.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 3. 25.
//

import SwiftUI

struct PickerRow: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [String]
    var color: Color
    
    @State private var scaleEffect: CGFloat = 1.0

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .scaleEffect(scaleEffect)
                .animation(.spring(), value: selection)
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selection) { _, _ in
                scaleEffect = 1.2
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation { scaleEffect = 1.0 }
                }
            }
        }
    }
}

//#Preview {
//    PickerRow(icon: <#String#>, title: <#String#>, selection: <#Binding<String>#>, options: <#[String]#>, color: <#Color#>)
//}
