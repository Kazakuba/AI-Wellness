//
//  DeliveryTimeView.swift
//  AiWellness
//
//  Created by Kazakuba on 24. 4. 25.
//

import SwiftUI

struct DeliveryTimeView: View {
    @State private var viewModel = DeliveryTimeViewModel()
    @State private var showConfirmationAlert = false
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Daily Affirmation Time").foregroundColor(isDarkMode ? .white : .black)) {
                DatePicker(
                    "Select Time",
                    selection: $viewModel.selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .foregroundColor(isDarkMode ? .white : .black)
            }
            
            Section {
                Button("Save & Schedule Notification") {
                    viewModel.saveSelectedTime()
                    showConfirmationAlert = true
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(isDarkMode ? .white : .black)
            }
            .alert("Saved", isPresented: $showConfirmationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your daily affirmation will be delivered at \(viewModel.formattedTime(viewModel.selectedTime))")
                    .foregroundColor(isDarkMode ? .white : .black)
            }
        }
        .navigationTitle("Delivery Time")
        .background(AppBackgroundGradient.main(isDarkMode))
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    DeliveryTimeView()
}
