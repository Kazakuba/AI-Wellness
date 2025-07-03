//
//  Exstensions.swift
//  AiWellness
//
//  Created by Kazakuba on 16.1.25..
//

import Foundation

extension Date {
    func daysAgo() -> Int {
        let calendar = Calendar.current
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfNow = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startOfSelf, to: startOfNow)
        return components.day ?? 0
    }
}
