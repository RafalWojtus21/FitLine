//
//  DateExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 26/05/2023.
//

import Foundation

extension Date {
    
    func minutes(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: date, to: self)
        return components.minute ?? 0
    }
}
