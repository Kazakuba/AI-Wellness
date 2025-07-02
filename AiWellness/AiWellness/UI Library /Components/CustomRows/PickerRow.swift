//
//  PickerRow.swift
//  AiWellness
//
//  Created by Kazakuba on 10. 3. 25.
//

import SwiftUI

struct PickerRow: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [String]
    var color: Color
    
    @State private var scaleEffect: CGFloat = 1.0
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDarkMode ? .white : .black)
                .frame(width: 30, height: 30)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .scaleEffect(scaleEffect)
                .animation(.spring(), value: selection)
            
            Text(title)
                .foregroundColor(isDarkMode ? .white : .black)
            Picker("", selection: $selection) { // Empty label to avoid duplicate title
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .foregroundColor(isDarkMode ? .white : .black)
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
        .listRowBackground(isDarkMode ? Color(red: 35/255, green: 35/255, blue: 38/255) : Color.customSystemGray6)
    }

}

//#Preview {
//    PickerRow(icon: <#String#>, title: <#String#>, selection: <#Binding<String>#>, options: <#[String]#>, color: <#Color#>)
//}
