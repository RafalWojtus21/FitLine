//
//  NSPredicateExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 14/04/2023.
//

import Foundation

extension NSPredicate {
    static func matchPredicate(regex: Validation.ValidationType.RegexPatterns) -> NSPredicate {
        return NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
    }
}
