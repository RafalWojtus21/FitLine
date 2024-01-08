//
//  UIImageExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit

extension UIImage {
    static func assetImageName(_ name: AssetImage) -> UIImage? {
        return UIImage(named: name.rawValue)
    }
    
    static func systemImageName(_ name: SystemImage) -> UIImage? {
        return UIImage(systemName: name.rawValue)
    }
}

enum AssetImage: String {
    case welcomeScreenBackground
}

enum SystemImage: String {
    case personCircleFill = "person.circle.fill"
    case personCircle = "person.circle"
    case calendarIcon = "calendar"
    case homeIcon = "house"
    case settingsIcon = "gearshape"
    case plusIcon = "plus"
    case plusCircleIcon = "plus.circle"
    case rightArrow = "chevron.right"
    case flame = "flame"
    case bell = "bell"
    case workoutIcon = "figure.highintensity.intervaltraining"
    case recordsIcon = "medal"
}
