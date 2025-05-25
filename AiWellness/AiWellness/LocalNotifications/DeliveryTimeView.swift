//
//  DeliveryTimeView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 24. 4. 25.
//

import SwiftUI

struct DeliveryTimeView: View {
    @State private var viewModel = DeliveryTimeViewModel()
    @State private var showConfirmationAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Daily Affirmation Time")) {
                DatePicker(
                    "Select Time",
                    selection: $viewModel.selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
            }
            
            Section {
                Button("Save & Schedule Notification") {
                    viewModel.saveSelectedTime()
                    showConfirmationAlert = true
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .alert("Saved", isPresented: $showConfirmationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your daily affirmation will be delivered at \(viewModel.formattedTime(viewModel.selectedTime))")
            }
        }
        .navigationTitle("Delivery Time")
    }
}

#Preview {
    DeliveryTimeView()
}
