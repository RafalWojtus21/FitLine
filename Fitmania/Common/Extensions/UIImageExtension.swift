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
}

enum AssetImage: String {
    case welcomeScreenBackground
}
