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
    
    var firstLetterCapitalized: String {
        return prefix(1).capitalized + dropFirst()
    }
    
    var withTrailingSlash: String {
        if self.hasSuffix("/") {
            return self
        } else {
            return self + "/"
        }
    }
}
