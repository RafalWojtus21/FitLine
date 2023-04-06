//
//  StringExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/04/2023.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
