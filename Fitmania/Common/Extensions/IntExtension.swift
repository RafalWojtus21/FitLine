//
//  IntExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 29/05/2023.
//

import Foundation

extension Int {
    static func calculateFormattedDuration(duration: Int) -> String {
        typealias L = Localization.General
        
        var formattedDuration: String
        switch duration {
        case 0 ..< 60:
            let secondsForm = duration == 1 ? L.secondsSingularForm : L.secondsPluralForm
            formattedDuration = "\(duration) \(secondsForm)"
        case 60 ..< 3600:
            let minutes = duration / 60
            let seconds = duration % 60
            let minutesForm = minutes == 1 ? L.minutesSingularForm : L.minutesPluralForm
            let minutesString = "\(minutes) \(minutesForm)"
            let secondsForm = seconds == 1 ? L.secondsSingularForm : L.secondsPluralForm
            let secondsString = "\(seconds) \(secondsForm)"
            formattedDuration = "\(minutesString) \(secondsString)"
        default:
            let hours = duration / 3600
            let minutes = (duration % 3600) / 60
            let seconds = (duration % 3600) % 60
            let hoursForm = hours == 1 ? L.hoursSingularForm : L.hoursPluralForm
            let hoursString = "\(hours) \(hoursForm)"
            let minutesForm = minutes == 1 ? L.minutesSingularForm : L.minutesPluralForm
            let minutesString = "\(minutes) \(minutesForm)"
            let secondsForm = seconds == 1 ? L.secondsSingularForm : L.secondsPluralForm
            let secondsString = "\(seconds) \(secondsForm)"
            formattedDuration = "\(hoursString) \(minutesString) \(secondsString)"
        }
        return formattedDuration
    }
}
