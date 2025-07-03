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
    private var cancellable: AnyCancellable?
    private let checkInterval: TimeInterval = 30

    init() {
        checkServerStatus()
        Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            self?.checkServerStatus()
        }
    }

    func checkServerStatus() {
        GeminiAPIService.shared.ping { [weak self] isUp in
            DispatchQueue.main.async {
                self?.isServerUp = isUp
            }
        }
    }

    deinit {}
}
