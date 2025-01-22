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
    private var timer: Timer?

    init() {
        startServerStatusTimer()
    }

    deinit {
        stopServerStatusTimer()
    }

    private func startServerStatusTimer() {
        stopServerStatusTimer() // Ensure no duplicate timers
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkServerStatus()
        }
        timer?.fire() // Immediately check status
    }

    private func stopServerStatusTimer() {
        timer?.invalidate()
        timer = nil
    }

    func checkServerStatus() {
        OllamaService.shared.checkServerStatus { [weak self] isUp in
            DispatchQueue.main.async {
                self?.isServerUp = isUp
            }
        }
    }
}
