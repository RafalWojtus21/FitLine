//
//  DateExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import Foundation

extension DateFormatter {
    
    enum DateFormat: String {
        case dayMonth = "dd.MM"
        case dayMonthString = "dd MMMM"
        case hourMinute = "HH:mm"
        case dayMonthHourMinute = "dd.MM HH:mm"
    }
    
    static var dayMonthDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dayMonth.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
    
    static var dayMonthStringDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dayMonthString.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()

    static var hourMinuteDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.hourMinute.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
    
    static var dayMonthHourMinuteDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dayMonthHourMinute.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
}