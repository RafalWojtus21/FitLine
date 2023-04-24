//
//  Localization.AuthErrors.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 24/04/2023.
//

import Foundation

extension Localization {
    enum AuthErrors {
        static let signUpError = "AuthError.SignupError".localized
        static let loginError = "AuthError.LoginError".localized
        static let userNotLoggedIn = "AuthError.UserNotLoggedIn".localized
        static let invalidEmail = "AuthError.InvalidEmail".localized
        static let weakPassword = "AuthError.WeakPassword".localized
        static let emailAlreadyInUse = "AuthError.EmailAlreadyInUse".localized
        static let wrongPassword = "AuthError.WrongPassword".localized
        static let unauthenticatedUser = "AuthError.UnauthenticatedUser".localized
        static let userNotFound = "AuthError.UserNotFound".localized
    }
}
