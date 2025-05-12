//
//  ServerStatusViewModel.swift
//  AiWellness
//
//  Created by Kazakuba on 21.1.25..
//

import Combine
import Foundation

class ServerStatusViewModel: ObservableObject {
    @Published var isServerUp: Bool? = nil

    init() {
        // Removed server status timer as it is no longer needed
        isServerUp = true // Default to true or handle as per new logic
    }

    deinit {
        // No cleanup needed as timer is removed
    }
}
