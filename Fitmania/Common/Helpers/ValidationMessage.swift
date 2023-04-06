//
//  ValidationMessage.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/04/2023.
//

import Foundation

struct ValidationMessage: Equatable {
    var message: String?
    var isValid: Bool { message == nil }
}
