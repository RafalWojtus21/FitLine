//
//  Error.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import Foundation

enum AuthError: Error, Equatable {
    case signUpError
    case loginError
}
