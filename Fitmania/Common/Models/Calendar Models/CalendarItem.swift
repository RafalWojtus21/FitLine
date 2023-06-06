//
//  CalendarItem.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import Foundation

struct CalendarItem: Equatable {
    let date: Date
    let isCurrentMonth: Bool
    let finishedWorkout: [FinishedWorkout]?
}

struct CalendarMonth: Equatable {
    let calendarItems: [CalendarItem]
    let monthAndYear: String
}
